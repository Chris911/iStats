/*
 * Apple System Management Control (SMC) Tool
 * Copyright (C) 2006 devnull
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include <stdio.h>
#include <string.h>
#include <ruby.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>

#include "smc.h"

static io_connect_t conn;

UInt32 _strtoul(char *str, int size, int base)
{
    UInt32 total = 0;
    int i;

    for (i = 0; i < size; i++)
    {
        if (base == 16)
            total += str[i] << (size - 1 - i) * 8;
        else
           total += (unsigned char) (str[i] << (size - 1 - i) * 8);
    }
    return total;
}

float _strtof(unsigned char *str, int size, int e)
{
    float total = 0;
    int i;

    for (i = 0; i < size; i++)
    {
        if (i == (size - 1))
            total += (str[i] & 0xff) >> e;
        else
            total += str[i] << (size - 1 - i) * (8 - e);
    }

	total += (str[size-1] & 0x03) * 0.25;

    return total;
}

void _ultostr(char *str, UInt32 val)
{
    str[0] = '\0';
    sprintf(str, "%c%c%c%c",
            (unsigned int) val >> 24,
            (unsigned int) val >> 16,
            (unsigned int) val >> 8,
            (unsigned int) val);
}

kern_return_t SMCOpen(void)
{
    kern_return_t result;
    mach_port_t   masterPort;
    io_iterator_t iterator;
    io_object_t   device;

    result = IOMasterPort(MACH_PORT_NULL, &masterPort);

    CFMutableDictionaryRef matchingDictionary = IOServiceMatching("AppleSMC");
    result = IOServiceGetMatchingServices(masterPort, matchingDictionary, &iterator);
    if (result != kIOReturnSuccess)
    {
        printf("Error: IOServiceGetMatchingServices() = %08x\n", result);
        return 1;
    }

    device = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    if (device == 0)
    {
        printf("Error: no SMC found\n");
        return 1;
    }

    result = IOServiceOpen(device, mach_task_self(), 0, &conn);
    IOObjectRelease(device);
    if (result != kIOReturnSuccess)
    {
        printf("Error: IOServiceOpen() = %08x\n", result);
        return 1;
    }

    return kIOReturnSuccess;
}

kern_return_t SMCClose()
{
    return IOServiceClose(conn);
}


kern_return_t SMCCall(int index, SMCKeyData_t *inputStructure, SMCKeyData_t *outputStructure)
{
    size_t   structureInputSize;
    size_t   structureOutputSize;

    structureInputSize = sizeof(SMCKeyData_t);
    structureOutputSize = sizeof(SMCKeyData_t);

    #if MAC_OS_X_VERSION_10_5
    return IOConnectCallStructMethod( conn, index,
                            // inputStructure
                            inputStructure, structureInputSize,
                            // ouputStructure
                            outputStructure, &structureOutputSize );
    #else
    return IOConnectMethodStructureIStructureO( conn, index,
                                                structureInputSize, /* structureInputSize */
                                                &structureOutputSize,   /* structureOutputSize */
                                                inputStructure,        /* inputStructure */
                                                outputStructure);       /* ouputStructure */
    #endif

}

kern_return_t SMCReadKey(UInt32Char_t key, SMCVal_t *val)
{
    kern_return_t result;
    SMCKeyData_t  inputStructure;
    SMCKeyData_t  outputStructure;

    memset(&inputStructure, 0, sizeof(SMCKeyData_t));
    memset(&outputStructure, 0, sizeof(SMCKeyData_t));
    memset(val, 0, sizeof(SMCVal_t));

    inputStructure.key = _strtoul(key, 4, 16);
    inputStructure.data8 = SMC_CMD_READ_KEYINFO;

    result = SMCCall(KERNEL_INDEX_SMC, &inputStructure, &outputStructure);
    if (result != kIOReturnSuccess)
        return result;

    val->dataSize = outputStructure.keyInfo.dataSize;
    _ultostr(val->dataType, outputStructure.keyInfo.dataType);
    inputStructure.keyInfo.dataSize = val->dataSize;
    inputStructure.data8 = SMC_CMD_READ_BYTES;

    result = SMCCall(KERNEL_INDEX_SMC, &inputStructure, &outputStructure);
    if (result != kIOReturnSuccess)
        return result;

    memcpy(val->bytes, outputStructure.bytes, sizeof(outputStructure.bytes));

    return kIOReturnSuccess;
}

double SMCGetTemperature(char *key)
{
    SMCVal_t val;
    kern_return_t result;

    result = SMCReadKey(key, &val);
    if (result == kIOReturnSuccess) {
        // read succeeded - check returned value
        if (val.dataSize > 0) {
            if (strcmp(val.dataType, DATATYPE_SP78) == 0) {
                // convert fp78 value to temperature
                int intValue = (val.bytes[0] * 256 + val.bytes[1]) >> 2;
                return intValue / 64.0;
            }
        }
    }
    // read failed
    return 0.0;
}

float SMCGetFanSpeed(int fanNum)
{
    SMCVal_t val;
    kern_return_t result;

    UInt32Char_t  key;
    sprintf(key, SMC_KEY_FAN_SPEED, fanNum);
    result = SMCReadKey(key, &val);
    return _strtof(val.bytes, val.dataSize, 2);
}

int SMCGetFanNumber(char *key)
{
    SMCVal_t val;
    kern_return_t result;

    result = SMCReadKey(key, &val);
    return _strtoul((char *)val.bytes, val.dataSize, 10);
}

/* Battery info
 * Ref: http://www.newosxbook.com/src.jl?tree=listings&file=bat.c
 *      https://developer.apple.com/library/mac/documentation/IOKit/Reference/IOPowerSources_header_reference/Reference/reference.html
 */
void dumpDict (CFDictionaryRef Dict)
{
    // Helper function to just dump a CFDictioary as XML
    CFDataRef xml = CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)Dict);
    if (xml) { write(1, CFDataGetBytePtr(xml), CFDataGetLength(xml)); CFRelease(xml); }
}

CFDictionaryRef powerSourceInfo(int Debug)
{
    CFTypeRef       powerInfo;
    CFArrayRef      powerSourcesList;
    CFDictionaryRef powerSourceInformation;

    powerInfo = IOPSCopyPowerSourcesInfo();

    if(! powerInfo) return NULL;

    powerSourcesList = IOPSCopyPowerSourcesList(powerInfo);
    if(!powerSourcesList) {
        CFRelease(powerInfo);
        return NULL;
    }

    // Should only get one source. But in practice, check for > 0 sources
    if (CFArrayGetCount(powerSourcesList))
    {
        powerSourceInformation = IOPSGetPowerSourceDescription(powerInfo, CFArrayGetValueAtIndex(powerSourcesList, 0));

        if (Debug) dumpDict (powerSourceInformation);

        //CFRelease(powerInfo);
        //CFRelease(powerSourcesList);
        return powerSourceInformation;
    }

    CFRelease(powerInfo);
    CFRelease(powerSourcesList);
    return NULL;
}

int getDesignCycleCount() {
    CFDictionaryRef powerSourceInformation = powerSourceInfo(0);

    if(powerSourceInformation == NULL)
        return 0;

    CFNumberRef designCycleCountRef = (CFNumberRef)  CFDictionaryGetValue(powerSourceInformation, CFSTR("DesignCycleCount"));
    uint32_t    designCycleCount;
    if ( ! CFNumberGetValue(designCycleCountRef,  // CFNumberRef number,
                            kCFNumberSInt32Type,  // CFNumberType theType,
                            &designCycleCount))   // void *valuePtr);
        return 0;
    else
        return designCycleCount;
}

const char* getBatteryHealth() {
    CFDictionaryRef powerSourceInformation = powerSourceInfo(0);

    if(powerSourceInformation == NULL)
        return "Unknown";

    CFStringRef batteryHealthRef = (CFStringRef) CFDictionaryGetValue(powerSourceInformation, CFSTR("BatteryHealth"));

    const char *batteryHealth = CFStringGetCStringPtr(batteryHealthRef, // CFStringRef theString,
                                                kCFStringEncodingMacRoman); //CFStringEncoding encoding);
    if(batteryHealth == NULL)
        return "unknown";

    return batteryHealth;
}

/*
 RUBY MODULES
*/
VALUE CPU_STATS = Qnil;
VALUE FAN_STATS = Qnil;
VALUE BATTERY_STATS = Qnil;
/*
 * Define Ruby modules and associated methods
 * We never call this, Ruby does.
*/
void Init_osx_stats() {
    CPU_STATS = rb_define_module("CPU_STATS");
    rb_define_method(CPU_STATS, "get_cpu_temp", method_get_cpu_temp, 0);

    FAN_STATS = rb_define_module("FAN_STATS");
    rb_define_method(FAN_STATS, "get_fan_number", method_get_fan_number, 0);
    rb_define_method(FAN_STATS, "get_fan_speed", method_get_fan_speed, 1);

    BATTERY_STATS = rb_define_module("BATTERY_STATS");
    rb_define_method(BATTERY_STATS, "get_battery_health", method_get_battery_health, 0);
    rb_define_method(BATTERY_STATS, "get_battery_design_cycle_count", method_get_battery_design_cycle_count, 0);
    rb_define_method(BATTERY_STATS, "get_battery_temp", method_get_battery_temp, 0);
    rb_define_method(BATTERY_STATS, "get_battery_time_remaining", method_get_battery_time_remaining, 0);
    rb_define_method(BATTERY_STATS, "get_battery_charge", method_get_battery_charge, 0);
}

VALUE method_get_cpu_temp(VALUE self) {
    SMCOpen();
    double temp = SMCGetTemperature(SMC_KEY_CPU_TEMP);
    SMCClose();

    return rb_float_new(temp);
}

VALUE method_get_fan_number(VALUE self) {
    SMCOpen();
    int num = SMCGetFanNumber(SMC_KEY_FAN_NUM);
    SMCClose();

    return INT2NUM(num);
}

VALUE method_get_fan_speed(VALUE self, VALUE num) {
    uint fanNum = NUM2UINT(num);
    SMCOpen();
    float speed = SMCGetFanSpeed(fanNum);
    SMCClose();

    return rb_float_new(speed);
}

VALUE method_get_battery_health(VALUE self) {
    const char* health = getBatteryHealth();
    return rb_str_new2(health);
}

VALUE method_get_battery_design_cycle_count(VALUE self) {
    int cc = getDesignCycleCount();
    return INT2NUM(cc);
}

VALUE method_get_battery_temp(VALUE self) {
    SMCOpen();
    double temp = SMCGetTemperature(SMC_KEY_BATTERY_TEMP);
    SMCClose();

    return rb_float_new(temp);
}

VALUE method_get_battery_time_remaining(VALUE self) {
  CFTimeInterval time_remaining;

  time_remaining = IOPSGetTimeRemainingEstimate();

  if (time_remaining == kIOPSTimeRemainingUnknown) {
    return rb_str_new2("Calculating");
  } else if (time_remaining == kIOPSTimeRemainingUnlimited) {
    return rb_str_new2("Unlimited");
  } else {
    return INT2NUM(time_remaining);
  };
};

VALUE method_get_battery_charge(VALUE self) {
  CFNumberRef currentCapacity;
  CFNumberRef maximumCapacity;

  int iCurrentCapacity;
  int iMaximumCapacity;
  int charge;

  CFDictionaryRef powerSourceInformation;

  powerSourceInformation = powerSourceInfo(0);
  if (powerSourceInformation == NULL)
    return Qnil;

  currentCapacity = CFDictionaryGetValue(powerSourceInformation, CFSTR(kIOPSCurrentCapacityKey));
  maximumCapacity = CFDictionaryGetValue(powerSourceInformation, CFSTR(kIOPSMaxCapacityKey));

  CFNumberGetValue(currentCapacity, kCFNumberIntType, &iCurrentCapacity);
  CFNumberGetValue(maximumCapacity, kCFNumberIntType, &iMaximumCapacity);

  charge = (float)iCurrentCapacity / iMaximumCapacity * 100;

  return INT2NUM(charge);
};

/* Main method used for test */
// int main(int argc, char *argv[])
// {
//     //SMCOpen();
//     //printf("%0.1f°C\n", SMCGetTemperature(SMC_KEY_CPU_TEMP));
//     //printf("%0.1f\n", SMCGetFanSpeed(0));
//     //printf("%0.1f\n", SMCGetFanSpeed(3));
//     //printf("%i\n", SMCGetFanNumber(SMC_KEY_FAN_NUM));
//     //SMCClose();
//
//     int designCycleCount = getDesignCycleCount();
//     const char* batteryHealth = getBatteryHealth();
//
//   	if (designCycleCount) printf ("%i\n", designCycleCount);
//     if (batteryHealth) printf ("%s\n", batteryHealth);
//
//     return 0;
// }

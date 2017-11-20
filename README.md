iStats [![Gem Version](https://badge.fury.io/rb/iStats.svg)](http://badge.fury.io/rb/iStats)
======

iStats is a command-line tool that allows you to easily grab the CPU temperature, fan speeds and battery information on OS X. If you'd like to see more data available feel free to open an issue.

## Installation

    $ gem install iStats

##### Note
If you are running an older version of OS X and the install fails you might want to try running this command instead:     
`sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future gem install iStats`

## Screenshot
#### All Stats
![](http://i.imgur.com/c4xLB8u.png)

#### Sparkline levels
![](http://i.imgur.com/ht2NZCL.gif)

## Usage

```
  - iStats: help ---------------------------------------------------

  istats --help                        This help text
  istats --version                     Print current version

  # Commands
  istats all                           Print all stats
  istats cpu                           Print all CPU stats
  istats cpu [temp | temperature]      Print CPU temperature
  istats fan                           Print all fan stats
  istats fan [speed]                   Print fan speed
  istats battery                       Print all battery stats
  istats battery [health]              Print battery health
  istats battery [time | remain]       Print battery time remaining
  istats battery [cycle_count | cc]    Print battery cycle count info
  istats battery [temp | temperature]  Print battery temperature
  istats battery [charge]              Print battery charge
  istats battery [capacity]            Print battery capacity info

  istats scan                          Scans and print temperatures
  istats scan [key]                    Print single SMC temperature key
  istats scan [zabbix]                 JSON output for Zabbix discovery
  istats enable [key | all]            Enables key
  istats disable [key | all]           Disable key
  istats list                          List available keys

  # Arguments
  --no-graphs                          Don't display sparklines graphs
  --no-labels                          Don't display item names/labels
  --no-scale                           Display just the stat value
  --value-only                         No graph, label, or scale
  -f, --fahrenheit                     Display temperatures in fahrenheit

  for more help see: https://github.com/Chris911/iStats
```

## Advanced usage

iStats now supports extra sensors for advanced users. Here's how to enable that functionality:

1. Run `istats scan` to scan your computer for SMC sensors
2. Enable extra sensors by running `istats enable key` or `istats enable all`
3. Run `istats` or `istats extra` to see the extra sensors information.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

#### Tested on

<details>
  <summary>Click to expand</summary>
  <p>
    <br>
    MacBook Pro 2016    
    macOS: 10.12.6    
    Ruby: 2.4.1    
    <br>
    MacBook Pro 2011    
    OS X: 10.11.6    
    Ruby: 2.0.0    
    <br>
    MacBook Pro 2012    
    OS X: 10.9.3    
    Ruby: 1.9.3, 2.0.0, 2.1.1    
    <br>
    MacBook Pro 2014    
    OS X: 10.10.3, 10.10.4    
    Ruby: 2.1.3    
    <br>
    Mac Pro 2013    
    OS X: 10.12.6    
    Ruby: 2.0.0
  </p>
</details>   

#### Zabbix Integration

iStats has a "scan zabbix" mode which will emit JSON suitable for use with
[Zabbix](https://zabbix.com/) low-level discovery.  See the accompanying
template and agent config in the `integrations` directory.

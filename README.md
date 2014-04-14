iStats [![Gem Version](https://badge.fury.io/rb/iStats.svg)](http://badge.fury.io/rb/iStats)
======

Quick attempt at writing a Ruby wrapper for a small C library that interacts with the IOKit library (apple) to get the CPU temperature and fan speed. Will expand to more hardware data and stats in the future. 

#### Tested on
MacBook Pro 2012<br>
OS X 10.9.2<br>
Ruby: 1.9.3, 2.0.0, 2.1.1<br>

## Screenshot
#### All Stats
![](http://i.imgur.com/pNZwCmg.png)

#### Sparkline levels
![](http://i.imgur.com/ht2NZCL.gif)

## Installation

    $ gem install iStats

## Usage

```
  - iStats: help ---------------------------------------------------

  istats --help                            This help text
  istats --version                         Print current version

  istats all                               Print all stats
  istats cpu                               Print all CPU stats
  istats cpu [temp | temperature]          Print CPU temperature
  istats fan                               Print all fan stats
  istats fan [speed]                       Print fan speed

  for more help see: https://github.com/Chris911/iStats
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

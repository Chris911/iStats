iStats
======

Quick attempt at writing a Ruby wrapper for a small C library that interacts with the IOKit library (apple) to get the CPU temperature. Will expand to more hardware data and stats in the future. 

## Screenshot
![](http://i.imgur.com/ht2NZCL.gif)

## Installation

Add this line to your application's Gemfile:

    gem 'iStats'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iStats

## Usage

```
     - iStats: help ---------------------------------------------------

     istats --help                            This help text
     istats --version                         Print current version

     istats all                               Print all stats
     istats cpu                               Print all CPU stats
     istats cpu [temp | temperature]          Print CPU temperature

     for more help see: https://github.com/Chris911/iStats
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

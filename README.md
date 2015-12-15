# Mitos

This package can be used to control a Xs Duo Basic syringe pump. 
The package was implemented to enable integration of pump functions with other processes. 

## Installation

At the moment clone the repo as normal

## Basic Use

For basic use and testing:

```
bin/console
```

In IRB then use for example:

```ruby
pump = Mitos::XsDuoBasic.new(portname: "/dev/ttyUSBS0")
pump.start  #run initialisation routine
```

The two syringes are addressed with integers 0 and 1. 

Set the ports, from A to D. 

Set the rate in microlitres per minute.

Fill the syringe.

Empty the syringe.

```
pump.set_port(0,"A")
pump.set_rate(0,1000)
pump.fill_syringe(0)
pump.empty_syringe(0)
```

These commands are added to an internal queue and are run with.

```
pump.run
```

The sequence can be safely stopped at anytime with ctrl-c.

To clear the queue

```
pump.clear_queue
```

## Notes

At the moment Mitos has only been tested on Ubuntu. 

The syringe sizes are hard coded in mitos/lib/mitos/syringe.rb

More testing code is required for some pump functions

## TODO
A pause utility would be useful.

A continuous pumping operation would be useful. 





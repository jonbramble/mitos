lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

#require 'mitos'
#pump = Mitos::XsDuoBasic.new(portname: "COM4")

#pump.start

#pump.set_port(0,"A")
#pump.set_rate(0,1000)

#pump.set_port(1,"B")
#pump.set_rate(1,1000)

#pump.run

require 'irb'
IRB.start

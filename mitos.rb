require 'serialport'

module Mitos

	class XsDuoBasic
 
 	  ## COMMANDS ##
      INITIALIZE_SYRINGE = "I1"
      INITIALIZE_VALVE = "I2"
      STATUS = "S3"
      FLUSH = "F"
      SET_POSITION = "I3"
      STOP = "X"
      SET_PUMP_RATE = "E2 3"
      MOVE_SYRINGE_POS = "E2 1"
      MOVE_VALVE_POS = "E2 2"

      MYSTERY_V = "V"



	 def initialize(port)
		@sp = SerialPort.new(port,9600,8,1)

 		flush_coms
		init_syringes
	 end

	 def status
	 	read_15 = read_bytes(15)

        write(0,STATUS)
        puts read_15.call

        write(1,STATUS)
        str = read_15.call

        # parse inputs

        # check the input is of the correct format - regexp
        # split the string on spaces

        puts str.split(" ")

	 end

	private

   	 def flush_coms
		write(0,FLUSH)
		write(1,FLUSH)
		flush_input
	 end

	 def init_syringes

	 	read_7 = read_bytes(7)

		puts "Initialising pump valves"

		write(0,INITIALIZE_VALVE)
		puts read_7.call

		write(1,INITIALIZE_VALVE)
		puts read_7.call
		
		sleep(2)

		puts "Initialising syringes"

		write(0,INITIALIZE_SYRINGE)
		puts read_7.call
		
		write(1,INITIALIZE_SYRINGE)
		puts read_7.call

		flush_input
	 end

	 def flush_input
	 	@sp.flush_input
	 	sleep(1)
	 end

	 def write(pump,command)
	 	header = "$0"
		@sp.write(header+pump.to_s+command+"\r")
		sleep(0.25)
	 end

	 def read_bytes(n)
		return Proc.new {@sp.read(n)}
	 end

	end

end

pump = Mitos::XsDuoBasic.new("COM1")
pump.status

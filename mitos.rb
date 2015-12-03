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

      FOUR_PORT_A = "0"
      FOUR_PORT_B = "6"
      FOUR_PORT_C = "12"
      FOUR_PORT_D = "18"

      MYSTERY_V = "V"

      
	 def initialize(port)
		@sp = SerialPort.new(port,9600,8,1)

 		flush_coms
		init_syringes
	 end

	 def status
	 	#might have a problem if the number of bytes varies
        pump_command(0,STATUS)
        pump_command(1,STATUS)
	 end

	 def set_port(address,position)

	 end

	private

	 def parse_response(str)
	 	# check the input is of the correct format - regexp
	 	puts str
	 	res = str.split(" ")
	 	header = res[0].split("")
	 	type = header[3].to_i

	 	#for testing
	 	
	 	#command recieved
	 	if type==1
	 		puts "Command"
	 		puts res[1]
	 		## make some kind of response hash
	 	#status
	 	elsif type==9
	 		puts "Status"
	 		puts res[1]
	 	elsif type==8
	 		puts "Error, restart program"
	 	else
	 		puts "Unknown response"
	 	end

	 end

   	 def flush_coms
		write(0,FLUSH)
		write(1,FLUSH)
		flush_input
	 end

	 def init_syringes
		puts "Initialising pump valves"
		pump_command(0,INITIALIZE_VALVE)
		pump_command(1,INITIALIZE_VALVE)
		
		sleep(2)

		puts "Initialising syringes"
		pump_command(0,INITIALIZE_SYRINGE)
		pump_command(1,INITIALIZE_SYRINGE)

		flush_input
	 end


	 def pump_command(address,request)
	 	write(address,request)
	 	parse_response(read)
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

	 

	 def read
		begin
			str = @sp.readline(sep="\r")
		rescue EOFError
			puts "EOF"
		rescue Interupt
			puts "Write Interupt"
		end
		return str
	 end

	end

end

pump = Mitos::XsDuoBasic.new("COM1")
pump.status

#low level valve command
#pump.set_port(0,"A")

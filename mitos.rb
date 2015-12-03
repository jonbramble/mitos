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

      ZERO_POSITION = 30000

      # hard code syringe sizes for now
      SYRINGE_SIZE = 2500

      
	 def initialize(port)
		@sp = SerialPort.new(port,9600,8,1)

 		flush_coms
		init_syringes
	 end

	 def status
        pump_command(0,STATUS)
        pump_command(1,STATUS)
	 end

	 def set_syringe(address,position)

	 end

	 def fill_syringe(address)
	 	cmd = [MOVE_SYRINGE_POS,ZERO_POSITION].join(" ")
	 	pump_command(address,cmd)
	 end

	 def set_rate(address,rate)
	 	pos = rate*ZERO_POSITION/SYRINGE_SIZE
	 	cmd = [SET_PUMP_RATE,pos].join(" ")
	 	pump_command(address,cmd)
	 end

	 def stop(address)
	 	pump_command(address,STOP)	
	 end

	 def set_port(address,position)

	 	# check that the port is ready

	 	case position
	 	when "A"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_A].join(" ")
	 		pump_command(address,cmd)
	 	when "B"

	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_B].join(" ")
	 		pump_command(address,cmd)
	 	when "C"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_C].join(" ")
			pump_command(address,cmd)
	 	when "D"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_D].join(" ")
	 		pump_command(address,cmd)
	 	else
	 		puts "#{position} is not a valid port setting for this pump"
	 	end
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

# must stop if motors are busy

# need a listener and msg queue

#low level valve command
#pump.set_port(0,"A")

#pump.set_rate(0,1000)
#sleep(1)
#pump.set_port(0,"A")
#sleep(2)
#pump.fill_syringe(0)
require 'serialport'

module Mitos

	class CmdQ

		def initialize
			@q = Array.new
		end

		def push(command)
			@q.push(command)
		end

		def shift
			@q.shift
		end
	end


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
		@portname = port || "COM1"
		@sp = SerialPort.new(@portname,9600,8,1)
		@cmd_queue = CmdQ.new
	  end

	  def run
	  	#process the command queue
	  	#see flow diagram - recreate a logical construction of the process
	  	# on interupt rescue, stop pump, delete command queue and exit
	  	# may need to have unformatted cmds so we can id which type of command is being requested
	  	
	  	puts "processing command queue..."
	  	while cmd = @cmd_queue.shift
	  		write(cmd)
	  		str = listen
	  		puts str
	  		parse_response(str)
	  		# look at command response and wait or proceed on queue
	  	end
	  	puts "...command queue complete"

	  
	  end

	   def parse_response(str)
	 	# check the input is of the correct format - regexp
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


	  def listen
		@sp.readline(sep="\r")
	  end

	  def init
			puts "init"
			@cmd_queue.push(cmd_str(0,FLUSH))
			@cmd_queue.push(cmd_str(1,FLUSH))
			puts "Initialising pump valves"
			@cmd_queue.push(cmd_str(0,INITIALIZE_VALVE))
			@cmd_queue.push(cmd_str(1,INITIALIZE_VALVE))
			puts "Initialising syringes"
			@cmd_queue.push(cmd_str(0,INITIALIZE_SYRINGE))
			@cmd_queue.push(cmd_str(1,INITIALIZE_SYRINGE))
	  end

	  def status
	  		@cmd_queue.push(cmd_str(0,STATUS))
	  		@cmd_queue.push(cmd_str(1,STATUS))
	  end

	  def pump_command(address,request)
	 		write(address,request)
	  end

	  def write(cmd)
		 	@sp.write(cmd)
		 	sleep(0.25)
	  end

	  def cmd_str(address,request)
	  		header = "$0"
	  		header+address.to_s+request+"\r"
	  end

	  def flush_input
	 		@sp.flush_input
	 		sleep(1)
	  end

	  def fill_syringe(address)
	 	cmd = [MOVE_SYRINGE_POS,ZERO_POSITION].join(" ")
	 	@cmd_queue.push(command_str(address,cmd))
	 end

	 def set_rate(address,rate)
	 	pos = rate*ZERO_POSITION/SYRINGE_SIZE
	 	cmd = [SET_PUMP_RATE,pos].join(" ")
	 	@cmd_queue.push(command_str(address,cmd))
	 end

	 def set_port(address,position)

	 	# check that the port is ready

	 	case position
	 	when "A"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_A].join(" ")
	 		@cmd_queue.push(command_str(address,cmd))
	 	when "B"

	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_B].join(" ")
	 		@cmd_queue.push(command_str(address,cmd))
	 	when "C"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_C].join(" ")
			@cmd_queue.push(command_str(address,cmd))
	 	when "D"
	 		cmd = [MOVE_VALVE_POS,FOUR_PORT_D].join(" ")
	 		@cmd_queue.push(command_str(address,cmd))
	 	else
	 		puts "#{position} is not a valid port setting for this pump"
	 	end
	 end
	
	end

	#rep classes - might use later on 
	class Injector
	end

	class Syringe
	end

	class Valve
	end

end


#add all pump instructions to a command queue 
#process the command queue, waiting appropriately for the pumps and valves to move by monitoring the status signals
#main process will run through the queue

pump = Mitos::XsDuoBasic.new("COM1")
pump.init
pump.status

# we are done with commands, run the commands!
pump.run




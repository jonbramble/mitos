require 'serialport'

module Mitos

	class CommandQueue

		def initialize(address)
			@address = address
			@q = Array.new
		end

		def push(request)
			command = cmd_str(@address,request)
			@q.push(command)
		end

		def shift
			@q.shift
		end

		def each
			@q.each
		end

		def empty?
			@q.empty?
		end

		def first
			@q.first
		end

		def address
			@address
		end

		def cmd_str(address,request)
	  		header = "$0"
	  		header+address.to_s+request+"\r"
	  	end
	end

		#rep classes - might use later on 
	class Injector
		def initialize(address)
			@address = address
			@valve = Valve.new(address)
			@syringe = Syringe.new(address)
		end

		def address
			@address
		end

		def valve
			@valve
		end

		def syringe
			@syringe
		end
	end

	class Syringe

		SET_PUMP_RATE = "E2 3"
     	MOVE_SYRINGE_POS = "E2 1"
     	SET_POSITION = "I3"

     	ZERO_POSITION = 30000

     	# hard code syringe sizes for now
      	SYRINGE_SIZE = 2500

		def initialize(address)
			@address = address
		end

		def address
			@address
		end

		def fill_syringe(address)
	 		cmd = [MOVE_SYRINGE_POS,ZERO_POSITION].join(" ")
	 		@cmd_queue.push(cmd)
	 	end

	 	def set_rate(address,rate)
	 		pos = rate*ZERO_POSITION/SYRINGE_SIZE
	 		cmd = [SET_PUMP_RATE,pos].join(" ")
	 		@cmd_queue.push(cmd)
	 	end
	end

	class Valve

		MOVE_VALVE_POS = "E2 2"

      	FOUR_PORT_A = "0"
      	FOUR_PORT_B = "6"
      	FOUR_PORT_C = "12"
      	FOUR_PORT_D = "18"

		def initialize(address)
			@address = address
		end

		def address
			@address
		end

		def set_port(position)
			case position
	 		when "A"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_A].join(" ")		
	 		when "B"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_B].join(" ")
	 		when "C"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_C].join(" ")
	 		when "D"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_D].join(" ")
	 		else
	 		 puts "#{position} is not a valid port setting for this pump"
	 		end
	 		return cmd
		end


	end


	class XsDuoBasic

	  ## COMMANDS ##
      INITIALIZE_SYRINGE = "I1"
      INITIALIZE_VALVE = "I2"
      STATUS = "S3"
      FLUSH = "F"

      STOP = "X"
      
      MYSTERY_V = "V"

	  def initialize(port)
		@portname = port || "COM1"
		@sp = SerialPort.new(@portname,9600,8,1)
		@cmd_queue_0 = CommandQueue.new(0)
		@cmd_queue_1 = CommandQueue.new(1)

		@injector_0 = Injector.new(0)
		@injector_1 = Injector.new(1)

		init # adds startup sequence commands to queue
	  end

	  def run
	  	#process the command queue
	  	#see flow diagram - recreate a logical construction of the process
	  	# on interupt rescue, stop pump, delete command queue and exit
	  	# may need to have unformatted cmds so we can id which type of command is being requested

	  	#check that the ret valves are good to go

	  	#ensures that the queue is not empty for event loop
	  	status

	  	puts "processing command queue..."
	  	loop do

	  		#break out if queues are complete
	  		if @cmd_queue_0.empty? && @cmd_queue_1.empty?
	  			break
	  		end

	  		#start with queue 0 - how to I switch about between queues?

	  		cmd = @cmd_queue_0.shift
	  		puts "-> #{cmd}"
	  		write(cmd)

	  		
	  		begin
	  			str = listen
	  		rescue EOFError
	  			puts "No more messages from pump"
	  			break
	  		rescue Interupt
	  			puts "Operations halted"
	  			#write stop
	  			break
	  		end

	  		puts "<- #{str}"
	  		rep = parse_response(str)
	  		puts rep

	  		# look at command response and wait or proceed on queue

	  		# Is it a status message
	  		# Yes
	  		if rep[:status]
	  			process_status(rep)
	  		# No
	  		elsif !rep[:status]
	  			process_command(rep)
	  		else
	  			puts "unknown message type"
	  		end
	  	end
	  	puts "...command queue complete"

	  
	  end

	   def process_status(rep)
	   			address = rep[:address]
	  			#need to process queue for that address
	  			
	  			if address==1
	  				queue = @cmd_queue_1
	  				other_queue = @cmd_queue_0
	  			else
	  				queue = @cmd_queue_0
	  				other_queue = @cmd_queue_1
	  			end

				#command pending?
	  			#No
	  			if queue.empty?
	  				other_queue.push(STATUS)
	  			else 
	  				pending = queue.first
	  				puts pending
	  			end
	   end


	   def process_command(rep)
	   		address = rep[:address]

	   		if address==1
	  			queue = @cmd_queue_1
	  		else
	  			queue = @cmd_queue_0
	  		end

	   		case rep[:type]
	  			when 0
	  				puts "OK"
	  				queue.push(STATUS)
	  			when 1
	  				puts "Invalid Command"
	  				queue.push(STATUS)
	  			when 2
	  				puts "Busy - command ignored"
	  				queue.push(STATUS)
	  			when 3
	  				puts "Can't Process - input out of range or error"
	  				queue.push(STATUS)
	  			end

	   end

	   def parse_response(str)
	 	# check the input is of the correct format - regexp
	 	res = str.split(" ")
	 	header = res[0].split("")
	 	type = header[3].to_i

	 	address = header[2]
	 	
	 	rep = {address: address, error: :false, type: res[1]}	# response hash

	 	#for testing
	 	
	 	#command received
	 	if type==1
	 		rep[:status] = false
	 	elsif type==9
	 		rep[:status] = true
	 	elsif type==8
	 		rep[:error] = true
	 	else
	 		puts "Unknown response"
	 	end

	 	return rep

	 end

	  def listen
		@sp.readline(sep="\r")
	  end

	  def init
	  		## contains startup writes
			puts "Initialising pump ..."
			@cmd_queue_0.push(FLUSH)
			@cmd_queue_1.push(FLUSH)
			@cmd_queue_0.push(INITIALIZE_VALVE)
			@cmd_queue_1.push(INITIALIZE_VALVE)
			@cmd_queue_0.push(INITIALIZE_SYRINGE)
			@cmd_queue_1.push(INITIALIZE_SYRINGE)

			#separate init process start
	  		while !@cmd_queue_0.empty? do
	  			write(@cmd_queue_0.shift)
	  			str = listen
	  			rep = parse_response(str)
	  			puts rep
	  		end

	  		while !@cmd_queue_1.empty? do
	  			write(@cmd_queue_1.shift)
	  			str = listen
	  			rep = parse_response(str)
	  			puts rep
	  		end

	  		sleep(1)
	  		puts "Pump initialised"
	  end

	  def status
	  		@cmd_queue_0.push(STATUS)
	  		@cmd_queue_1.push(STATUS)
	  end

	  def write(cmd)
		 	@sp.write(cmd)
		 	sleep(0.25)
	  end

	  def flush_input
	 		@sp.flush_input
	 		sleep(1)
	  end


	  def set_rate(address,rate)
	  	injector = eval "@injector_#{address}"
	  	cmd = injector.syringe.set_rate(rate)
	  	write_to_queue(address,cmd)
	  end

	  def fill_syringe(address)
	  	injector = eval "@injector_#{address}"
	  	cmd = injector.syringe.fill_syringe
	  	write_to_queue(address,cmd)
	  end

      def set_port(address,position)
	 	
	 	injector = eval "@injector_#{address}"
	 	cmd = injector.valve.set_port(position)
	 	write_to_queue(address,cmd)
	 end

	 def write_to_queue(address,cmd)
	 	# check the address is 'suitable'
	 	queue = eval "@cmd_queue_#{address}"
	  	queue.push(cmd)
	 end
	
	end

end


#add all pump instructions to a command queue 
#process the command queue, waiting appropriately for the pumps and valves to move by monitoring the status signals
#main process will run through the queue

pump = Mitos::XsDuoBasic.new("COM1")

pump.set_port(0,"A")

# we are done with commands, run the commands!
pump.run





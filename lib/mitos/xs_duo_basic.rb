require 'rubyserial'

module Mitos

     class XsDuoBasic

	  ## COMMANDS ##
      	INITIALIZE_SYRINGE = "I1"
      	INITIALIZE_VALVE = "I2"
      	STATUS = "S3"
      	FLUSH = "F"
      	STOP = "X"
      	MYSTERY_V = "V"

	  def initialize(port)
		# might have to load in the port from another module
		@portname = port || "COM1"
		@sp = Serial.new(@portname,9600,8)

		@cmd_queue_0 = CommandQueue.new(0)
		@cmd_queue_1 = CommandQueue.new(1)

		@injector_0 = Injector.new(0)
		@injector_1 = Injector.new(1)
	  end

	  # run the init process and check that the pump is ready - otherwise end
	  def start
		init
	  end

	 ##
	 # Run the list of commands pushed onto the queues
	 # Never ending loop
	 # TODO: Fix the interrupt here - catch TERM signals
	 #
	  def run
	  	write_command_status(@cmd_queue_0)
	  	
	  	puts "processing command queue..."
	  	loop do
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

	  		rep = parse_response(str)

	  		# Look at command response and wait or proceed on queue

	  		# Is it a status message
	  		# Yes
	  		if rep[:status]
	  			process_status(rep)
	  		# No
	  		elsif !rep[:status]
	  			process_command(rep)
	  		else
	  			puts "Unknown message type"
	  		end
	  	end
	  	puts "...command queue complete"

	  end

	  def status
	  	prepend_queue(0,STATUS)
	  	prepend_queue(1,STATUS)
	  end

	 ##
         # set the pump rate in microlitres per minute
	 #
	  def set_rate(address,rate)
	  	injector = eval "@injector_#{address}"
	  	injector.syringe.rate = rate
	  	cmd = injector.syringe.get_rate_cmd
	  	add_to_queue(address,cmd)
	  end

	##
	# set the port valve
	# For the XsDuoBasic there are 4 valve positions, A, B, C, D
	#
      	def set_port(address,position)
	 	injector = eval "@injector_#{address}"
	 	injector.valve.position = position
	 	cmd = injector.valve.get_port_cmd
	 	add_to_queue(address,cmd)
	 end

	 ##
	 # completely fill the syringe
	 #
	  def fill_syringe(address)
	  	injector = eval "@injector_#{address}"
	  	cmd = injector.syringe.get_fill_cmd
	  	add_to_queue(address,cmd)
	  end

	##
	# completely empty the syringe
	# 
	 def empty_syringe(address)
		injector = eval "@injector_#{address}"
		cmd = injector.syringe.get_empty_cmd
		add_to_queue(address,cmd)
	 end

private

	##
	# Process the status message and run through the logical flow for the syringe and valve movement
	#
	def process_status(rep)
	   	address = rep[:address]	#need to process queue for that address
	  			
	  	if address==1
	  		queue = @cmd_queue_1
	  		injector = @injector_1
	  		other_queue = @cmd_queue_0
	  	else
	  		queue = @cmd_queue_0
	  		injector = @injector_0
	  		other_queue = @cmd_queue_1
	  	end

		# Write values from status process to the instance representations
	  	injector.syringe.motor = rep[:syringe_motor]
	  	injector.syringe.position = rep[:syringe_motor]
	  	injector.valve.motor = rep[:valve_motor]
	  	injector.valve.position = rep[:valve_position]

		#command pending?
	  	if queue.empty?#No
	  		puts "Queue empty"
	  		write_command_status(other_queue)
	  	else 
	  		if movement_cmd?(queue.first)
	  			puts "Movement command"
	  			if(injector.valve.motor == 1  && injector.syringe.motor == 1)
	  			 puts "Motors idle, running command"
	  			 write(queue.shift[:cmd])
	  			else
	  			 puts "Motors still moving switching queue"
	  			 write_command_status(other_queue)
	  			end
	  		else
	  			write(queue.shift[:cmd])
	  		end
	  	end
	  end

	#
	# We need to know if the next command will move the motors - could move this to the syringe and valve class 
	#
	  def movement_cmd?(cmd)
	  	ret = false
	  	req = cmd[:request].split(" ")
	  	if ["E2","I3"].include?(req[0])
	  		ret = true
	  	end
	  	return ret
	  end

	# 
	# Response commands from the pump are processed to return debug messages and to trigger status messages
	#
	 def process_command(rep)
	   		address = rep[:address]

	   		if address==1
	  			queue = @cmd_queue_1
	  		else
	  			queue = @cmd_queue_0
	  		end

	   		case rep[:type]
	  			when 0
	  				puts "Command OK"
	  			when 1
	  				puts "Invalid Command"	
	  			when 2
	  				puts "Busy - command ignored"		
	  			when 3
	  				puts "Can't Process - input out of range or error"
	  				
	  		end
	  		write_command_status(queue)
	 end

	##
	# Immediately write a status command to the pump
	#
	 def write_command_status(queue) 
	 	queue.unshift(STATUS)
	  	write(queue.shift[:cmd])
	 end

	 def parse_response(str)
	 	# check the input is of the correct format - regexp
	 	res = str.split(" ")
	 	header = res[0].split("")
	 	type = header[3].to_i

	 	address = header[2]
	 	
	 	rep = {address: address.to_i, error: :false, type: res[1].to_i}	# response hash
	 	
	 	#command received
	 	if type==1
	 		rep[:status] = false
	 	elsif type==9
	 		rep[:status] = true
	 		rep[:syringe_motor] = res[1].to_i
	 		rep[:valve_motor] = res[2].to_i
	 		rep[:syringe_position] = res[3].to_i
	 		rep[:valve_position] = res[4].to_i
	 	elsif type==8
	 		rep[:error] = true
	 	else
	 		puts "Unknown response"
	 	end

	 	return rep

	 end

	## 
	# Read from the serial port and retreive bytes upto the \r
	#
	 def listen
		rec = @sp.gets(sep="\r")
		puts "<- " + rec
		return rec
	 end

	##
	# Initialise the pump
	#
	 def init
	  	## contains startup writes
		puts "Initialising pump ..."

		#flush comms
		add_to_queue(0,FLUSH)
		add_to_queue(1,FLUSH)
		write(@cmd_queue_0.shift[:cmd])
		write(@cmd_queue_1.shift[:cmd])

		flush_input

		add_to_queue(0,INITIALIZE_VALVE)
		add_to_queue(1,INITIALIZE_VALVE)
		add_to_queue(0,INITIALIZE_SYRINGE)
		add_to_queue(1,INITIALIZE_SYRINGE)

		#separate init process start
	  	while !@cmd_queue_0.empty? do
	  		write(@cmd_queue_0.shift[:cmd])
	  		str = listen
	  		rep = parse_response(str)
	  		puts rep
	  	end

	  	while !@cmd_queue_1.empty? do
	  		write(@cmd_queue_1.shift[:cmd])
	  		str = listen
	  		rep = parse_response(str)
	  		puts rep
	  	end

	  	sleep(1)
	  	puts "Pump initialised"
		# could write and read a status message to set the valve and motor init states. 
	 end

	## 
	# adds a command to the end of the correct queue but doesn't write it to the pump
	#
	 def add_to_queue(address,cmd)
	 	queue = eval "@cmd_queue_#{address}"
	  	queue.push(cmd)
	 end

	## 
	# adds a command to the front of the correct queue but doesn't write it to the pump
	#
	 def prepend_queue(address,cmd)
	 	queue = eval "@cmd_queue_#{address}"
	 	queue.unshift(cmd)
	 end

	##
	# writes cmd to the serial port with a sleep time for the mitos pump to reply
	#
	 def write(cmd)
	 	 puts "-> "+ cmd
		 @sp.write(cmd)
		 sleep(0.25)
	 end

	##
	# We dont need to know the replies from the init commands
	#
	 def flush_input
	 	#@sp.flush_input
	 	@sp.read(7)
	 	@sp.read(7)
	 	sleep(1)
	 end
	
	end

end





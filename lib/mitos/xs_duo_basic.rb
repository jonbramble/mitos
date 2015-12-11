require 'rubyserial'
require 'logger'

module Mitos
     class XsDuoBasic

 	include Command

	 ## COMMANDS ##
      	INITIALIZE_SYRINGE = "I1"
      	INITIALIZE_VALVE = "I2"
      	STATUS = "S3"
      	FLUSH = "F"
      	STOP = "X"
      	MYSTERY_V = "V"

	  def initialize(args)
		# might have to load in the port from another module
		@portname = args[:portname] || "COM1"
		@sp = args[:port] || Serial.new(@portname,9600,8)

		@cmd_queue_0 = args[:queue_0] || CommandQueue.new(0)
		@cmd_queue_1 = args[:queue_1] || CommandQueue.new(1)

		@injector_0 = args[:injector_0] || Injector.new(0)
		@injector_1 = args[:injector_1] || Injector.new(1)

		@fill_port = "A"
		@waste_port = "C"

		logger

		return true
	  end

	  # run the init process and check that the pump is ready - otherwise end
	  def start
		init
	  end

	  def logger
	  	@log = Logger.new(STDOUT)
		@log.level = Logger::DEBUG
	  end

	  def log_level(level)
		@log.level = level
	  end

	  def show
		@log.info self
	  end

	  def clear_queue(address)
		queue = eval "@cmd_queue_#{address}"
		queue.clear
	  end

	  def list_commands(address)
		queue = eval "@cmd_queue_#{address}"
		queue.requests do |cmd|
		  puts cmd
		end
	  end

	 ##
	 # Run the list of commands pushed onto the queues
	 # Never ending loop
	 #
	  def run
	  	begin 
	  	write_command_status(@cmd_queue_0)
	  	
	  	@log.info "Processing command queue..."
	  	loop do
	  		begin
	  			str = listen
	  		rescue EOFError
	  			@log.error "No more messages from pump"
	  			break
	  		end

	  		rep = parse_response(str)

	  		# Look at command response and wait or proceed on queue

	  		# Is it a status message
	  		# Yes
	  		if rep[:status]
	  			ret = process_status(rep)
				@log.debug "status ret " + ret.to_s
				if ret
				 break
				end
	  		# No
	  		elsif !rep[:status]
	  			process_command(rep)
	  		else
	  			@log.error "Unknown message type"
	  		end
	  	end
	  	@log.info "...command queue complete"

	  	rescue IRB::Abort
	  		@log.error "Abort"
			sleep(0.25)
			write_stop
			#flush comms?
	  	rescue Interrupt
	  		@log.info "Interupt"
	  		#write_stop
	  	ensure 
	  		@log.info "Closing"
			#write_stop
	  	end

	  end

	  def close
		puts "close"
		@sp.close
	  end

	  def status
	  	prepend_queue(0,STATUS)
	  	prepend_queue(1,STATUS)
	  end

	  def quick_start
		start
		set_rate(0,2000)
		set_rate(1,2000)
		set_port(0,"A")
		set_port(1,"D")
		run
	  end

	def write_stop
		
		str = listen
		parse_response(str)
		 
		@cmd_queue_0.unshift(STOP)
		@cmd_queue_1.unshift(STOP)
	  	write(@cmd_queue_0.shift[:cmd])
		write(@cmd_queue_1.shift[:cmd])
		parse_response(listen)
		parse_response(listen)
	end

	 ##
         # set the pump rate in microlitres per minute
	 #
	  def set_rate(address,rate)
	  	injector = eval "@injector_#{address}"
	  	injector.syringe.rate = rate
	  	cmd = injector.syringe.get_rate_cmd
	  	add_to_queue(address,cmd)
		return true
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
		return true
	 end

	 ##
	 # completely fill the syringe
	 #
	  def fill_syringe(address)
	  	injector = eval "@injector_#{address}"
	  	cmd = injector.syringe.get_fill_cmd
	  	add_to_queue(address,cmd)
		return true
	  end

	 ##
	 # completely empty the syringe
	 # 
	 def empty_syringe(address)
		injector = eval "@injector_#{address}"
		cmd = injector.syringe.get_empty_cmd
		add_to_queue(address,cmd)
		return true
	 end

private

	##
	# Process the status message and run through the logical flow for the syringe and valve movement
	#
	def process_status(rep)
	   	address = rep[:address]	#need to process queue for that address
	  	ret = 0		
		empty = false

	  	if address==1
	  		queue = @cmd_queue_1
	  		injector = @injector_1
			other_injector = @injector_0
	  		other_queue = @cmd_queue_0
	  	else
	  		queue = @cmd_queue_0
	  		injector = @injector_0
			other_injector = @injector_1
	  		other_queue = @cmd_queue_1
	  	end

		# Write values from status process to the instance representations
	  	injector.syringe.motor = rep[:syringe_motor]
	  	injector.syringe.position = rep[:syringe_motor]
	  	injector.valve.motor = rep[:valve_motor]
	  	injector.valve.position = rep[:valve_position]

		
		these_motors = other_injector.valve.motor == 1 && injector.syringe.motor == 1
		other_motors = other_injector.valve.motor == 1 && other_injector.syringe.motor == 1
		motors = these_motors && other_motors
		empty = queue.empty? && other_queue.empty?		
		#exit condition - all motors have stopped, all commands have been run
		
		#command pending?
	  	if queue.empty?#No
	  		@log.debug "Queue empty"
			@log.debug "Other Queue empty " + other_queue.empty?.to_s
			write_command_status(other_queue)
	  	else 
	  		if movement_cmd?(queue.first)
	  			@log.debug "Movement command"
	  			if these_motors
	  			 @log.debug "Motors idle, running command"
	  			 write(queue.shift[:cmd])	
	  			else
	  			 @log.debug "Motors still moving switching queue"
	  			 write_command_status(other_queue)
	  			end
	  		else
	  			write(queue.shift[:cmd])
	  		end


	  	end

		@log.debug "e " + empty.to_s
		@log.debug "m " + motors.to_s
		return empty && motors
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
	  				@log.info "Command OK"
	  			when 1
	  				@log.error "Invalid Command"	
	  			when 2
	  				@log.error "Busy - command ignored"		
	  			when 3
	  				@log.error "Can't Process - input out of range or error"
	  				
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

	## 
	# Read from the serial port and retreive bytes upto the \r
	#
	 def listen
		rec = @sp.gets(sep="\r")
		@log.debug "Rx: " + rec
		return rec
	 end

	##
	# Initialise the pump
	#
	 def init
	  	## contains startup writes
		@log.info "Initialising pump ..."

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
			@log.debug rep
	  	end

	  	while !@cmd_queue_1.empty? do
	  		write(@cmd_queue_1.shift[:cmd])
	  		str = listen
	  		rep = parse_response(str)
			@log.debug rep
	  	end

	  	sleep(1)
	  	@log.info "Pump initialised"
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
	 	 @log.debug "Tx: "+cmd
		 @sp.write cmd
		 sleep 0.25 
	 end

	##
	# We dont need to know the replies from the init commands
	#
	 def flush_input
	 	@sp.read(7)
	 	@sp.read(7)
	 	sleep(1)
	 end
	
	end

end





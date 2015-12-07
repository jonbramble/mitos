require 'serialport'

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
		@sp = SerialPort.new(@portname,9600,8,1)

		@cmd_queue_0 = CommandQueue.new(0)
		@cmd_queue_1 = CommandQueue.new(1)

		@injector_0 = Injector.new(0)
		@injector_1 = Injector.new(1)
	  end

	  def start
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
	  	
	  	#pp @cmd_queue_0.inspect
	  	#pp @cmd_queue_1.inspect

	  	queue = @cmd_queue_0
	  	other_queue = @cmd_queue_1

	  	puts "processing command queue..."
	  	loop do
	  		#break out if queues are complete
	  		if @cmd_queue_0.empty? && @cmd_queue_1.empty?
	  			break
	  		end

	  		#start with queue 0 - how to I switch about between queues?
	  		# alternate? - may not need this if we have exe commands in flow ??

	  		if !queue.empty?
	  			cmd = queue.shift[:cmd]
	  			puts "-> #{cmd}"
	  			write(cmd)
	  		end

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
	  		#puts rep

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

	  		## swap queues 
	  		tmp_queue = queue
	  		queue = other_queue
	  		other_queue = tmp_queue
	  	end
	  	puts "...command queue complete"

	  
	  end

	  def status
	  	write_to_front(0,STATUS)
	  	write_to_front(1,STATUS)
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

private

	def process_status(rep)
	   	address = rep[:address]
	  			#need to process queue for that address
	  			
	  	if address==1
	  		queue = @cmd_queue_1
	  		injector = @injector_1
	  		other_queue = @cmd_queue_0
	  	else
	  		queue = @cmd_queue_0
	  		injector = @injector_0
	  		other_queue = @cmd_queue_1
	  	end

	  	injector.syringe.motor = rep[:syringe_motor]
	  	injector.syringe.position = rep[:syringe_motor]
	  	injector.valve.motor = rep[:valve_motor]
	  	injector.valve.position = rep[:valve_position]

	  	puts injector.inspect

		#command pending?
	  	#No
	  	if queue.empty?
	  		puts "queue empty"
	  		other_queue.push(STATUS)
	  	else 
	  		pending = queue.first
	  		mov = parse_command(pending)
	  		if mov
	  			if(injector.valve.motor == 1  && injector.syringe.motor == 1)
	  			 cmd = queue.shift[:cmd]
	  			 write(cmd)
	  			else
	  			 puts "Motors still moving"
	  			 other_queue.push(STATUS)
	  			end
	  		  else
	  		  	cmd = queue.shift[:cmd]
	  			write(cmd)
	  		  end
	  	end
	   end

	  def parse_command(cmd)
	  	# reverse the command type! 
	  	res = cmd.split(" ")
	 	header = res[0].split("")
	 	type = header[3]
	 	# needs to look at next value if it is present as E2 3 is not a moving
	 	if ["E","I"].include?(type)
	 		ret = true
	 	end
	 	#puts type
	 	#puts ret
	 	return ret
	  end

	 def process_command(rep)
	   		address = rep[:address]

	   		if address==1
	  			queue = @cmd_queue_1
	  		else
	  			queue = @cmd_queue_0
	  		end

	   		case rep[:type].to_i
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
	 		rep[:syringe_motor] = res[1]
	 		rep[:valve_motor] = res[2]
	 		rep[:syringe_position] = res[3]
	 		rep[:valve_position] = res[4]
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

		#flush comms
		write_to_queue(0,FLUSH)
		write_to_queue(1,FLUSH)
		write(@cmd_queue_0.shift)
		write(@cmd_queue_1.shift)

		flush_input

		write_to_queue(0,INITIALIZE_VALVE)
		write_to_queue(1,INITIALIZE_VALVE)
		write_to_queue(0,INITIALIZE_SYRINGE)
		write_to_queue(1,INITIALIZE_SYRINGE)

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
	 end

	 def write_to_queue(address,cmd)
	 	# check the address is 'suitable'
	 	queue = eval "@cmd_queue_#{address}"
	  	queue.push(cmd)
	 end

	 def write_to_front(address,cmd)
	 	queue = eval "@cmd_queue_#{address}"
	 	queue.unshift(cmd)
	 end

	 def write(cmd)
		 @sp.write(cmd)
		 sleep(0.25)
	 end

	 def flush_input
	 	@sp.flush_input
	 	sleep(1)
	 end
	
	end

end


#add all pump instructions to a command queue 
#process the command queue, waiting appropriately for the pumps and valves to move by monitoring the status signals
#main process will run through the queue

#pump = Mitos::XsDuoBasic.new("COM1")

#pump.set_port(0,"B")
#pump.set_rate(0,1000)

#pump.set_port(1,"B")
#pump.set_rate(1,1500)

# we are done with commands, run the commands!
#pump.run





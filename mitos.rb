require 'serialport'

class Mitos

	def initialize(port)
		@sp = SerialPort.new(port,9600,8,1)

 		flush_coms
		#init_syringes
		status
	end

	def status
        @sp.write("$01S3\n")
        sleep(0.25)
        while data = @sp.readline
        	puts data
        end
        #@sp.write("$01S3\n")
        #sleep(0.25)
        #puts @sp.readline
        #@sp.flush_input
	end

	def run
   	 puts "Listening on serial port #{@portname}"
    
   	 @sp.flush_input
     begin 
 		while data = @sp.readline
 			#parse_input(data)
 			puts data
 		end
 	    rescue Interrupt
  		 puts "exiting"	
  	end

   end

private

   	def flush_coms
		@sp.write("$00F\n")
		sleep(0.25)
		@sp.write("$01F\n")
		sleep(0.25)
		@sp.flush_input
	end

	def init_syringes
		puts "Initialising pump valves"
		@sp.write("$00I2\r\n")
		sleep(0.25)
		@sp.write("$01I2\r\n")
		sleep(0.25)
		sleep(2)
		puts "Initialising syringes"
		@sp.write("$00I1\r\n")
		sleep(0.25)
		@sp.write("$01I1\r\n")
		sleep(0.25)
		sleep(2)
	end

end

m = Mitos.new("COM1")


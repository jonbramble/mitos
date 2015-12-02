require 'serialport'

class Mitos

	def initialize(port)
		@sp = SerialPort.new(port,9600,8,1)

 		flush_coms
		init_syringes
		status
	end

	def status

        @sp.write("$00S3\r")
        sleep(0.25)
  
        puts @sp.read(15)

        @sp.write("$01S3\r")
        sleep(0.25)

        puts @sp.read(15)
		sleep(1)

		puts("port")
		

        @sp.write("$01E2 2 16\r")
        puts @sp.read(7)

	end

private

   	def flush_coms
		@sp.write("$00F\r")
		sleep(0.25)
		@sp.write("$01F\r")
		sleep(0.25)
		#@sp.flush_input
	end

	def init_syringes
		sleep(1)
		puts "Initialising pump valves"
		@sp.write("$00I1\r")
		sleep(0.25)
		puts @sp.read(7)

		@sp.write("$01I2\r")
		sleep(0.25)
		puts @sp.read(7)
		
		sleep(2)
		puts "Initialising syringes"
		@sp.write("$00I1\r")
		sleep(0.25)
		puts @sp.read(7)
		
		@sp.write("$01I1\r")
		sleep(0.25)
		puts @sp.read(7)

		
		
		#sleep(0.25)
		sleep(2)
		@sp.flush_input
	end

end

m = Mitos.new("COM1")


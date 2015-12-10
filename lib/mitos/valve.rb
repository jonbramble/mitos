module Mitos

	# Valve represents the current state of a pump valve
	#
	# Initialised with the injector address
	#
	# Attributes are set from calls to pump status
	#
	# Commands returned must be written to the pump
	#
	# * Initialised - the state of the valve after correct startup
	# * Position - the letter representing the valve position
	# * Motor - the status of the motor, 1= idle, 2=moving
	#
	# ==== Examples
	# 	
	#   valve = Valve.new(0)
	#
	#
	class Valve

		attr_reader :address
		attr_accessor :initialised, :position, :motor

		MOVE_VALVE_POS = "E2 2"

      		FOUR_PORT_A = "0"
      		FOUR_PORT_B = "6"
      		FOUR_PORT_C = "12"
      		FOUR_PORT_D = "18"

		def initialize(address)
			@address = address
			@initialised = false
			@position = "A"
			@motor = 0
		end

		## 
		# Returns the command string for pump settings by letter
		#
		def get_port_cmd
			case @position
	 		when "A"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_A].join(" ")		
	 		when "B"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_B].join(" ")
	 		when "C"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_C].join(" ")
	 		when "D"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_D].join(" ")
	 		else
	 		 puts "#{@position} is not a valid port setting for this pump - resetting to A"
	 		 cmd = [MOVE_VALVE_POS,FOUR_PORT_A].join(" ")
	 		end
	 		return cmd
		end

		##
		# Returns the valve status as a hash of values 
		#
		def status
			{address: @address, position: @position, motor: @motor}
		end


	end
end

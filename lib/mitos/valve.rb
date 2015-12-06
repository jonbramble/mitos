module Mitos
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

		def set_port(letter)
			case letter
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

		def status
			#return status info about valve state
		end


	end
end

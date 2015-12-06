module Mitos
	class Syringe
  
  		attr_reader :address 
		attr_accessor :position, :motor, :initialised
		
		SET_PUMP_RATE = "E2 3"
     		MOVE_SYRINGE_POS = "E2 1"
     		SET_POSITION = "I3"

     		ZERO_POSITION = 30000

     		# hard code syringe sizes for now
      		SYRINGE_SIZE = 2500

		def initialize(address)
			@address = address
			@position = 0
			@motor = 0
		end

		def fill_syringe(address)
	 		cmd = [MOVE_SYRINGE_POS,ZERO_POSITION].join(" ") 
	 	end

	 	def set_rate(rate)
	 		pos = rate*ZERO_POSITION/SYRINGE_SIZE
	 		cmd = [SET_PUMP_RATE,pos].join(" ")
	 	end

	 	def status
	 		# return status info
	 	end
	end
end

module Mitos

	# Syringe represents the current state of a pump syringe
	#
	# Initialised with the injector address
	#
	# Attributes are set from calls to pump status
	#
	# Commands returned must be written to the pump
	#
	# * Position - position of the syringe in microns
	# * Motor - the status of the motor, 1= idle, 2=moving
	#
	class Syringe
  
  		attr_reader :address 
		attr_accessor :position, :motor, :initialised, :rate
		
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
			@rate = 0
		end

		## 
		# Returns the command string for syringe fill
		#
		def get_fill_cmd
	 		cmd = [MOVE_SYRINGE_POS,ZERO_POSITION].join(" ") 
	 	end
		
		## 
		# Returns the command string for pump settings by letter
		#
	 	def get_rate_cmd
	 		pos = rate*ZERO_POSITION/SYRINGE_SIZE
	 		cmd = [SET_PUMP_RATE,pos].join(" ")
	 	end

		##
		# Returns the syringe status as a hash of values 
		#
	 	def status
	 		{address: @address, position: @position, motor: @motor, rate: @rate}
	 	end
	end
end

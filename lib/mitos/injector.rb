require_relative 'syringe'
require_relative 'valve'

module Mitos

	class Injector

		attr_reader :address, :valve, :syringe

		def initialize(address)
			@address = address
			@valve = Valve.new(address)
			@syringe = Syringe.new(address)
		end
	end



end
module Mitos
	class CommandQueue

		attr_reader :address

		def initialize(address)
			@address = address
			@q = Array.new
		end

		def push(request)
			command = cmd_str(request)
			@q.push(command)
		end

		def shift
			@q.shift
		end

		def size
			@q.size
		end

		def subscribe
			@q.shift
		end

		def unshift(val)
			command = cmd_str(val)
			@q.unshift(command)
		end

		#def each
		#	@q.each
		#end

		def empty?
			@q.empty?
		end

		def first
			@q.first
		end

	private

		def cmd_str(request)
	  		header = "$0"
	  		header+@address.to_s+request+"\r"
	  	end
	end
end


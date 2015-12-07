module Mitos
	class CommandQueue

		attr_reader :address

		def initialize(address)
			@address = address
			@q = Array.new
		end

		def push(request)
			command = cmd_str(request)
			command_entry = entry(command,request)
			@q.push(command_entry)
		end

		def entry(command,request)
			{cmd: command, address: @address, request: request, time_stamp: Time.now}
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

		def unshift(request)
			command = cmd_str(request)
			command_entry = entry(command,request)
			@q.unshift(command_entry)
		end

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


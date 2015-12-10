module Mitos
	module Command

	 def parse_response(str)
	 	# check the input is of the correct format - regexp
	 	res = str.split(" ")
	 	header = res[0].split("")
	 	msg_type = header[3].to_i
 		rsp_type = res[1].to_i

	 	address = header[2].to_i
	 	
	 	rep = {address: address, sensor_error: false}	# response hash
	 	
	 	#command received
	 	if msg_type==1
	 		rep[:status] = false
			rep[:type] = rsp_type
	 	elsif msg_type==9
	 		rep[:status] = true
	 		rep[:syringe_motor] = res[1].to_i
	 		rep[:valve_motor] = res[2].to_i
	 		rep[:syringe_position] = res[3].to_i
	 		rep[:valve_position] = res[4].to_i
	 	elsif msg_type==8
	 		rep[:sensor_error] = true
	 	else
	 		@log.error "Unknown response"
	 	end

	 	return rep

	 end

	#
	# We need to know if the next command will move the motors - could move this to the syringe and valve class 
	#
	 def movement_cmd?(cmd)
	  	ret = false
	  	req = cmd[:request].split(" ")
	  	if ["E2","I3"].include?(req[0])
	  		ret = true
	  	end
	  	return ret
	  end

	end
end

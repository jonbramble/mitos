require 'spec_helper'

RSpec.describe Mitos::Command do

describe "#parse_response" do
  let(:dummy_class) { Class.new { extend Mitos::Command } }
  #include Mitos::Command
  it "parses a command received from address 0" do
  	cmd = "#001 0"
  	res = {address: 0, sensor_error: false, type: 0, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses a command received from address 0" do
  	cmd = "#011 0"
  	res = {address: 1, sensor_error: false, type: 0, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses an invalid command received from address 0" do
  	cmd = "#001 1"
  	res = {address: 0, sensor_error: false, type: 1, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses an invalid command received from address 1" do
  	cmd = "#011 1"
  	res = {address: 1, sensor_error: false, type: 1, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses a busy command received from address 0" do
  	cmd = "#001 2"
  	res = {address: 0, sensor_error: false, type: 2, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses a busy command received from address 1" do
  	cmd = "#011 2"
  	res = {address: 1, sensor_error: false, type: 2, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

   it "parses a range error command received from address 0" do
  	cmd = "#001 3"
  	res = {address: 0, sensor_error: false, type: 3, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses a range error command received from address 1" do
  	cmd = "#011 3"
  	res = {address: 1, sensor_error: false, type: 3, status: false}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses status command received from address 0" do
  	cmd = "#009 1 1 0 0 "
  	res = {address: 0, sensor_error: false, syringe_motor: 1, valve_motor: 1, syringe_position: 0, valve_position: 0, status: true}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses status command received from address 1" do
  	cmd = "#019 1 1 0 0 "
  	res = {address: 1, sensor_error: false, syringe_motor: 1, valve_motor: 1, syringe_position: 0, valve_position: 0, status: true}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end

  it "parses status command received from address 1" do
  	cmd = "#009 2 1 3000 0 "
  	res = {address: 0, sensor_error: false, syringe_motor: 2, valve_motor: 1, syringe_position: 3000, valve_position: 0, status: true}
  	expect(dummy_class.parse_response(cmd)).to eq(res)
  end


end

end
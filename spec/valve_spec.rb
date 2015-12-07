require 'spec_helper'

RSpec.describe Mitos::Valve do

context "set port" do
 before(:each) do
  @address= 0
  @v = Mitos::Valve.new(@address)
 end

 describe "#get_port_cmd to A" do
  it "forms the correct command string" do
   @v.position = "A"
   expect(@v.get_port_cmd).to eq("E2 2 0")
  end
 end

 describe "#get_port_cmd to B" do
   it "forms the correct command string" do
    @v.position = "B"
   expect(@v.get_port_cmd).to eq("E2 2 6")
  end
 end

 describe "#get_port_cmd to C" do
   it "forms the correct command string" do
    @v.position = "C"
   expect(@v.get_port_cmd).to eq("E2 2 12")
  end
 end

 describe "#get_port_cmd to D" do
   it "forms the correct command string" do
    @v.position = "D"
   expect(@v.get_port_cmd).to eq("E2 2 18")
  end
 end

end

context "status message" do
   
 before(:each) do
  @address= 0
  @v = Mitos::Valve.new(@address)
 end
 describe "#status" do
	it "returns the correct address in status hash" do
		expect(@v.status[:address]).to eq(@address)
	end

	it "returns the correct position in status hash" do
		expect(@v.status[:position]).to eq("A")
	end

  it "returns the correct position in status hash after change" do
    @v.position = "B"
    expect(@v.status[:position]).to eq("B")
  end

	it "returns the correct motor in status hash" do
		expect(@v.status[:motor]).to eq(0)
	end
 end

end
 


end

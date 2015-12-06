require 'spec_helper'

RSpec.describe Mitos::Valve do

context "set port" do
 before(:each) do
  @address= 0
  @v = Mitos::Valve.new(@address)
 end

 describe "#set_port to A" do
  it "forms the correct command string" do
   expect(@v.set_port("A")).to eq("E2 2 0")
  end
 end

 describe "#set_port to B" do
   it "forms the correct command string" do
   expect(@v.set_port("B")).to eq("E2 2 6")
  end
 end

 describe "#set_port to C" do
   it "forms the correct command string" do
   expect(@v.set_port("C")).to eq("E2 2 12")
  end
 end

 describe "#set_port to D" do
   it "forms the correct command string" do
   expect(@v.set_port("D")).to eq("E2 2 18")
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

	it "returns the correct motor in status hash" do
		expect(@v.status[:motor]).to eq(0)
	end
 end

end
 


end

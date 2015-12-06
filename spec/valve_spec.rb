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
 


end

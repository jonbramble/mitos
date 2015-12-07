require 'spec_helper'

RSpec.describe Mitos::Syringe do

	context "#set_rate" do
		before(:each) do
			@address = 0
			@syringe = Mitos::Syringe.new(@address)
		end

		describe "#get_fill_cmd" do
			it "returns the correct command string" do
				expect(@syringe.get_fill_cmd).to eq("E2 1 30000")
			end
		end

		describe "#set_rate" do
			it "returns the correct command string" do
				@syringe.rate = 10
				expect(@syringe.get_rate_cmd).to eq("E2 3 120")
			end
		end

	end

	context "status message" do
   
 	before(:each) do
  		@address= 0
  		@s = Mitos::Syringe.new(@address)
 	end
 	describe "#status" do
	it "returns the correct address in status hash" do
		expect(@s.status[:address]).to eq(@address)
	end

	it "returns the correct position in status hash" do
		expect(@s.status[:position]).to eq(0)
	end

  	it "returns the correct position in status hash after change" do
    	@s.position = 100
    	expect(@s.status[:position]).to eq(100)
  	end

	it "returns the correct motor in status hash" do
		expect(@s.status[:motor]).to eq(0)
	end

	it "returns the correct rate in status hash" do
		expect(@s.status[:rate]).to eq(0)
	end

 end

end


end


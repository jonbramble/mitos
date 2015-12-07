require 'spec_helper'

RSpec.describe Mitos::CommandQueue do
context "queue" do

 before(:each) do
  @address = 0
  @cmd_queue = Mitos::CommandQueue.new(@address)
 end

 describe "#empty?" do
  it "returns empty on initialisation" do
   expect(@cmd_queue.empty?).to be true
  end
 end

 describe "#size" do
  it "returns empty on initialisation" do
   expect(@cmd_queue.size).to eq(0)
  end

  it "returns size 1 after an addition" do
   request = "A"
   @cmd_queue.push(request)
   expect(@cmd_queue.size).to eq(1)
  end
 end

 describe "#push" do
  it "adds elements to the internal array" do
   request = "A"
   @cmd_queue.push(request)
   expect(@cmd_queue.empty?).to be false
 end
 
  it "changes the size of the array" do
    request = "A"
    expect { @cmd_queue.push(request) }.to change{@cmd_queue.size}.by(1)
 end
end

 describe "#first" do
  it "access first element of internal array" do
   @cmd_queue.push("A")
   str = "$0#{@address}A\r"
   expect(@cmd_queue.first[:cmd]).to eq(str)
   expect { @cmd_queue.first[:cmd] }.not_to change{@cmd_queue.size}
 end
end

 describe "#address" do
   it "returns the address for a new queue" do
     expect(@cmd_queue.address).to eq(@address)
   end
 end

## these tests are also testing push because I dont want to give access to the internal array directly
describe "#subscribe" do
  before(:each) do
   ["A","B","C"].each{ |req|  @cmd_queue.push(req) }
  end

  it "removes the first element from the array" do
   str = "$0#{@address}A\r"
   expect(@cmd_queue.subscribe[:cmd]).to eq(str)
   str = "$0#{@address}B\r"
   expect(@cmd_queue.subscribe[:cmd]).to eq(str)
 end

 it "changes the size of the array" do
  @cmd_queue.push("A")
  expect { @cmd_queue.subscribe }.to change{@cmd_queue.size}.by(-1)
 end

end

describe "#unshift" do
 it "changes the size of the array" do
  @cmd_queue.push("A")
  expect { @cmd_queue.unshift("B") }.to change{@cmd_queue.size}.by(1)
 end

 it "adds a request at the front of the array" do
  @cmd_queue.push("A")
  @cmd_queue.unshift("B")
  str = "$0#{@address}B\r"
  expect(@cmd_queue.subscribe[:cmd]).to eq(str)
 end
end

end

end

require 'spec_helper'

#double port obj
class SPort

end

RSpec.describe Mitos::XsDuoBasic do

describe "#status" do
  it "writes commands to front of queue" do
  	p = Mitos::XsDuoBasic.new(port: SPort.new)

  end
end

end

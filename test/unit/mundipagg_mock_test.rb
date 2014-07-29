require_relative '../test_helper'
require_relative '../gateway_mock'

describe MundipaggMock do
  before do
    MundipaggMock.setup
    @client = Mundipagg::Gateway.new :production
  end
  
  it "should hook into Mundipagg's SendToService method" do
    @client.SendToService({a: "a"}, :method)
    MundipaggMock.calls.last[:hash].must_equal a: "a"
    MundipaggMock.calls.last[:method_name].must_equal :method
  end

  it 'should enable setting up the responses' do
  end
end

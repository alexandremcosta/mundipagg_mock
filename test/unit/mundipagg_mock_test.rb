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

  describe '.clear' do
    it 'should clear the calls array' do
      @client.SendToService({}, :method)
      MundipaggMock.clear
      MundipaggMock.calls.length.must_equal 0
    end
  end

  describe '.respond_with' do
    it 'should enable setting up the responses' do
      MundipaggMock.respond_with key: "value"
      @client.SendToService({},:method).must_equal key: "value"
    end
  end

  describe '.responder=' do
    it 'should enable setting responders' do
      MundipaggMock.responder = ->(hash, method){ method }
      @client.SendToService({},:a).must_equal :a
      @client.SendToService({},:b).must_equal :b
    end
  end
end

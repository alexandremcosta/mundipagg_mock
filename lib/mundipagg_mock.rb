module MundipaggMock
  class << self
    attr_reader :calls
    def setup
      @calls = []
      Mundipagg::Gateway.instance_eval do
        define_method :SendToService do |hash, method|
          MundipaggMock.calls << {hash: hash, method_name: method}
        end
      end
    end
  end
end

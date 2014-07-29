module MundipaggMock
  class << self
    attr_reader :calls
    attr_accessor :responder

    def setup
      @calls = []
      @responder = ->(hash,method){nil}
      Mundipagg::Gateway.instance_eval do
        define_method :SendToService do |hash, method|
          MundipaggMock.calls << {hash: hash, method_name: method}
          MundipaggMock.responder.call(hash, method)
        end
      end
    end

    def respond_with response
      self.responder = ->(hash,method){ response }
    end
  end
end

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
    
    def clear
      @calls = []
    end

    def respond_with response
      self.responder = ->(hash,method){ response }
    end

    def approve_all
      self.responder = ->(hash,method) do
        req = hash["tns:createOrderRequest"]

        ccs = req["mun:CreditCardTransactionCollection"]
        ccs = ccs && ccs["mun:CreditCardTransaction"]
        ccs = ccs || []

        bol = req["mun:BoletoTransactionCollection"]
        bol = bol && bol["mun:BoletoTransaction"]
        bol = bol || []

        MundipaggMock.build_response_hash({
          order_reference: req["mun:OrderReference"],
          boleto_transaction_result_collection: bol && {
            boleto_transaction_result: begin
              arr = bol.map do |t|
                {
                  transaction_reference: t["mun:TransactionReference"],
                  amount_in_cents: t["mun:AmountInCents"],
                  nosso_numero: t["mun:NossoNumero"]
                }
              end
              arr.length <= 1 ? arr.first : arr
            end
          }, 
          credit_card_transaction_result_collection: ccs && {
            credit_card_transaction_result: begin
              arr = ccs.map do |t|
                MundipaggMock.build_cc_hash({
                  transaction_reference: t["mun:TransactionReference"],
                  amount_in_cents: t["mun:AmountInCents"],
                  captured_amount_in_cents: t["mun:CapturedAmountInCents"]
                })
              end
              arr.length <= 1 ? arr.first : arr
            end
          }
        })
      end
    end

    def build_response_hash result={}
      {:create_order_response=>
        {:create_order_result=>
          {:buyer_key=>"00000000-0000-0000-0000-000000000000",
           :merchant_key=>"00000000-0000-0000-0000-000000000000",
           :mundi_pagg_time_in_milliseconds=>"358",
           :order_key=>"00000000-0000-0000-0000-000000000000",
           :order_reference=>"Order Ref",
           :order_status_enum=>"Paid",
           :request_key=>"00000000-0000-0000-0000-000000000000",
           :success=>true,
           :version=>"1.0",
           :credit_card_transaction_result_collection=> nil,
           :boleto_transaction_result_collection=>nil,
           :mundi_pagg_suggestion=>nil,
           :error_report=>nil,
           :"@xmlns:a"=>"http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts",
           :"@xmlns:i"=>"http://www.w3.org/2001/XMLSchema-instance"
         }.merge(result),
         :@xmlns=>"http://tempuri.org/"
        }
      }
    end

    def build_cc_hash cc={}
      {
        :acquirer_message=>"Transação de simulação autorizada com sucesso",
        :acquirer_return_code=>"0",
        :amount_in_cents=>"1000",
        :authorization_code=>"221672",
        :authorized_amount_in_cents=>"1000",
        :captured_amount_in_cents=>"1000",
        :credit_card_number=>"411111****1111",
        :credit_card_operation_enum=>"AuthAndCapture",
        :credit_card_transaction_status_enum=>"Captured",
        :custom_status=>nil,
        :due_date=>nil,
        :external_time_in_milliseconds=>"76",
        :instant_buy_key=>"00000000-0000-0000-0000-000000000000",
        :refunded_amount_in_cents=>nil,
        :success=>true,
        :transaction_identifier=>"774353",
        :transaction_key=>"00000000-0000-0000-0000-000000000000",
        :transaction_reference=>"Custom Transaction Identifier",
        :unique_sequential_number=>"383884",
        :voided_amount_in_cents=>nil,
        :original_acquirer_return_collection=>nil
      }.merge(cc)
    end

    def b_hash b={}
      {
        amount_paid_in_cents:"0",
        bar_code: "1234567890",
        boleto_transaction_status_enum: "Paid",
        boleto_url: "http://www.example.com/",
        nosso_numero: "123456789",
        transaction_key: "00000000-0000-0000-0000-000000000000",
        custom_status: "Status",
        transaction_reference: "Custom Transaction Identifier"
      }
    end
  end
end

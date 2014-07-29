require 'mundipagg'
require_relative '../test_helper'

describe MundipaggMock do
  before do
    MundipaggMock.setup
    @client = Mundipagg::Gateway.new :production
  end
  
  describe '.approve_all' do
    before do
      MundipaggMock.approve_all
      #Create the order
      @order = Mundipagg::CreateOrderRequest.new

      #Fill order information
      @order.amountInCents = 1000 # R$ 10,00
      @order.amountInCentsToConsiderPaid = 1000
      @order.merchantKey = '00000000-0000-0000-0000-000000000000'
      @order.orderReference = 'Custom Order 42'
    end

    it 'should have the same order attributes' do
      result = @client.CreateOrder(@order)[:create_order_response][:create_order_result]
      result[:order_reference].must_equal @order.orderReference
    end
    
    describe 'Credit card transactions' do

      before do
        #Credit card transaction information
        @credit = Mundipagg::CreditCardTransaction.new

        @credit.amountInCents = 5000 # R$ 50,00
        @credit.creditCardBrandEnum = Mundipagg::CreditCardTransaction.BrandEnum[:Visa]
        @credit.creditCardOperationEnum = Mundipagg::CreditCardTransaction.OperationEnum[:AuthAndCapture]
        @credit.creditCardNumber = '4111111111111111'
        @credit.holderName = 'Anthony Edward Stark'
        @credit.installmentCount = 1
        @credit.paymentMethodCode = 1 #Simulator
        @credit.securityCode = 123
        @credit.transactionReference = 'Custom Transaction Identifier'
        @credit.expirationMonth = 5
        @credit.expirationYear = 2020

        #Add transaction to order
        @order.creditCardTransactionCollection << @credit
        
        @result = @client.CreateOrder(@order)[:create_order_response][:create_order_result]
        @it = @result[:credit_card_transaction_result_collection]
        @it = @it[:credit_card_transactions_result].first
      end
      
      it 'should set the basic transaction infos' do
        @it[:transaction_reference].must_equal @credit.transactionReference
        @it[:amount_in_cents].must_equal @credit.amountInCents
      end
    end
  end
end

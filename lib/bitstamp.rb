require 'active_support/core_ext'
require 'active_support/inflector'
require 'active_model'
require 'curb'
require 'hmac-sha2'

require 'bitstamp/net'
require 'bitstamp/helper'
require 'bitstamp/collection'
require 'bitstamp/model'

require 'bitstamp/orders'
require 'bitstamp/transactions'
require 'bitstamp/ticker'

String.send(:include, ActiveSupport::Inflector)

module Bitstamp
  # API Key
  mattr_accessor :key

  # Bitstamp secret
  mattr_accessor :secret

  # Bitstamp client ID
  mattr_accessor :client_id

  # Currency
  mattr_accessor :currency
  @@currency = :usd

  def self.orders
    self.sanity_check!

    @@orders ||= Bitstamp::Orders.new
  end

  def self.user_transactions
    self.sanity_check!

    @@transactions ||= Bitstamp::UserTransactions.new
  end

  def self.transactions
    return Bitstamp::Transactions.from_api
  end

  def self.balance
    self.sanity_check!

    JSON.parse Bitstamp::Net.post('/balance').body_str
  end

  def self.withdraw_bitcoins(options = {})
    self.sanity_check!
    if options[:amount].nil? || options[:address].nil?
      raise MissingConfigExeception.new("Required parameters not supplied, :amount, :address")
    end
    response_body = Bitstamp::Net.post('/bitcoin_withdrawal',options).body_str
    if response_body != 'true'
      return JSON.parse response_body
    else
      return response_body
    end
  end
  def self.bitcoin_deposit_address
    # returns the deposit address
    self.sanity_check!
    return Bitstamp::Net.post('/bitcoin_deposit_address').body_str
  end

  def self.unconfirmed_user_deposits
    self.sanity_check!
    return JSON.parse Bitstamp::Net::post("/unconfirmed_btc").body_str
  end

  def self.ticker
    return Bitstamp::Ticker.from_api
  end

  def self.order_book
    return JSON.parse Bitstamp::Net.get('/order_book/').body_str
  end

  def self.setup
    yield self
  end

  def self.configured?
    self.key && self.secret && self.client_id
  end

  def self.sanity_check!
    unless configured?
      raise MissingConfigExeception.new("Bitstamp Gem not properly configured")
    end
  end

  class MissingConfigExeception<Exception;end;
end

# frozen_string_literal: true

require 'base64'

module Borica
  # Request is a representation of what the documentation refers to as a
  # BOReq object.
  #
  # This is all the data that is passed to the Borica system as the
  # eBorica query parameter. It needs to be signed with the provided SSL
  # certificates.
  class Request
    TRANSACTION_TYPES = [
      10, # Authorization
      11, # Payment
      21, # Request delayed authorization
      22, # Execute delayed authorization
      23, # Reverse request delayed authorization
      40, # Reversal
      41  # Reverse payment
    ]

    PROTOCOL_VERSIONS = [
      '1.0',
      '1.1',
      '2.0'
    ]

    CURRENCIES = [
      'USD',
      'EUR',
      'BGN'
    ]

    attr_reader :transaction_type
    attr_reader :transaction_timestamp
    attr_reader :transaction_amount
    attr_reader :terminal_id
    attr_reader :order_id
    attr_reader :order_summary
    attr_reader :language
    attr_reader :protocol_version
    attr_reader :currency
    attr_reader :one_time_ticket
    attr_reader :signature

    def initialize(transaction_type:,
                   transaction_amount:,
                   terminal_id:,
                   order_id:,
                   order_summary:,
                   signature:,
                   one_time_ticket: nil,
                   transaction_timestamp: Time.now,
                   language: 'EN',
                   protocol_version: '1.0',
                   currency: 'EUR')
      @transaction_type = validate(transaction_type.to_i, of: TRANSACTION_TYPES)
      @transaction_timestamp = transaction_timestamp
      @transaction_amount = transaction_amount.to_s.sub('.', '')
      @terminal_id = terminal_id
      @order_id = order_id
      @order_summary = order_summary
      @language = language.to_s.upcase
      @protocol_version = validate(protocol_version.to_s, of: PROTOCOL_VERSIONS)
      @currency = validate(currency.to_s.upcase, of: CURRENCIES)
      @one_time_ticket = one_time_ticket
      @signature = signature
    end

    def to_s
      Base64.urlsafe_encode64(unsigned_content + signature.sign(unsigned_content))
    end

    private

    def validate(value, of:)
      unless of.include?(value)
        raise ArgumentError, "Expected one of #{of.inspect}, got: #{value.inspect}"
      end

      value
    end

    def fill(object, length, char: ' ', right: false)
      truncated = object.to_s[0...length]

      if right
        truncated.rjust(length, char)
      else
        truncated.ljust(length, char)
      end
    end

    def unsigned_content
      @unsigned_content ||= [
        fill(transaction_type, 2),
        fill(transaction_timestamp.strftime('%Y%m%d%H%M%S'), 14),
        fill(transaction_amount, 12, char: '0', right: true),
        fill(terminal_id, 8),
        fill(order_id, 15),
        fill(order_summary, 125),
        fill(language, 2),
        fill(protocol_version, 3),
        (fill(currency, 3) if protocol_version > '1.0'),
        (one_time_ticket if protocol_version == '2.0')
      ].compact.join
    end
  end
end

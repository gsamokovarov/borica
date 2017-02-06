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
      41, # Reverse payment
    ]

    attr_reader :transaction_type
    attr_reader :transaction_timestamp
    attr_reader :transaction_amount
    attr_reader :terminal_id
    attr_reader :order_id
    attr_reader :order_summary
    attr_reader :language
    attr_reader :protocol_version
    attr_reader :signature

    def initialize(transaction_type:,
                   transaction_amount:,
                   terminal_id:,
                   order_id:,
                   order_summary:,
                   signature:,
                   transaction_timestamp: Time.now,
                   language: 'EN',
                   protocol_version: '1.0')
      @transaction_type = ensure_valid_transaction_type(transaction_type)
      @transaction_timestamp = transaction_timestamp
      @transaction_amount = transaction_amount.to_s.sub('.', '')
      @terminal_id = terminal_id
      @order_id = order_id
      @order_summary = order_summary
      @language = language.to_s.upcase
      @protocol_version = protocol_version
      @signature = signature
    end

    def to_s
      Base64.urlsafe_encode64 [
        fill(transaction_type, 2),
        fill(transaction_timestamp.strftime('%Y%m%d%H%M%S'), 14),
        fill(transaction_amount, 12, char: '0', right: true),
        fill(terminal_id, 8),
        fill(order_id, 15),
        fill(order_summary, 125),
        fill(language, 2),
        fill(protocol_version, 3),
        fill(signature.sign, 128)
      ].join
    end

    private

    def ensure_valid_transaction_type(transaction_type)
      unless TRANSACTION_TYPES.include?(transaction_type.to_i)
        raise ArgumentError, "Invalid transaction type of #{transaction_type}, " \
                             "valid values are #{TRANSACTION_TYPES.inspect}"
      end

      transaction_type
    end

    def fill(object, length, char: ' ', right: false)
      truncated = object.to_s[0...length]

      if right
        truncated.rjust(length, char)
      else
        truncated.ljust(length, char)
      end
    end
  end
end

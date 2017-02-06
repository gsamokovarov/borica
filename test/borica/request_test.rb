# frozen_string_literal: true

require 'test_helper'

module Borica
  class RequestTest < Minitest::Test
    class FakeSignature
      def sign(_content)
        'G' * 128
      end
    end

    def test_general_request_base64_formatting
      request = Request.new transaction_type: 10,
                            transaction_amount: '99.99',
                            transaction_timestamp: Time.at(0),
                            terminal_id: '12345678',
                            order_id: '12345678',
                            order_summary: 'Money for fun!',
                            signature: FakeSignature.new

      expected_request = "MTAxOTcwMDEwMTAyMDAwMDAwMDAwMDAwOTk5OTEyMzQ1Njc4MTIzNDU2NzggICAgICAgTW9uZXkgZm9yIGZ1biEgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBFTjEuMEdHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dHR0dH"

      assert_equal expected_request, request.to_s
    end
  end
end

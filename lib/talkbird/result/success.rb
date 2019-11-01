# frozen_string_literal: true

module Talkbird
  module Result
    # Success monad (sort of).
    class Success

      attr_reader :body

      def initialize(result, body = nil)
        @result = result
        @body = parse_body(body)
      end

      def status_code
        @result.code
      end

      def parse_body(body)
        if body.nil?
          MultiJson.load(@result.body.to_s)
        elsif body.is_a?(String)
          MultiJson.load(body)
        else
          body
        end
      end

    end
  end
end

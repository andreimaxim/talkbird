# frozen_string_literal: true

module Talkbird
  module Result
    # Encapsulates a response from the API which should be considered a failed
    # request.
    class Failure

      attr_reader :body
      attr_reader :result

      def initialize(result)
        @result = result
        @body = MultiJson.load(result.body.to_s, symbolize_keys: true)
      end

      def code
        @body[:code]
      end

      def message
        @body[:message]
      end

    end
  end
end

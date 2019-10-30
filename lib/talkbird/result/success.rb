# frozen_string_literal: true

module Talkbird
  module Result
    # Success monad (sort of).
    class Success < Basic

      def initialize(result)
        @result = result
      end

      def status_code
        @result.code
      end

      def body
        MultiJson.load(@result.body.to_s)
      end

    end
  end
end

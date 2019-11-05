# frozen_string_literal: true

module Talkbird
  module Result
    # Class representing a result as an exception.
    class Exception

      attr_reader :body
      attr_reader :result
      attr_reader :exception

      def initialize(exception, result)
        @result = result
        @exception = exception
        @body = { error: exception.message }
      end

    end
  end
end

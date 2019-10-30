# frozen_string_literal: true

module Talkbird
  module Result
    # Class representing a result as an exception.
    class Exception < Basic

      def initialize(exception, result)
        @exception = exception
        @result = result
      end

    end
  end
end

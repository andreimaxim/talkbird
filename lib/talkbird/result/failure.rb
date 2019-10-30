# frozen_string_literal: true

module Talkbird
  module Result
    class Failure < Basic

      def initialize(result)
        @result = result
      end

    end
  end
end

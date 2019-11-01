# frozen_string_literal: true

module Talkbird
  # Encapsulation of the SendBird API responses.
  module Result

    # Select the right result type based on the response.
    def self.create(response)
      status_code = response.code

      if 200 <= status_code && status_code < 400
        PaginatedSuccess.new(response).reduce
      else
        Result::Failure.new(response)
      end
    rescue StandardError => exception
      Result::Exception.new(response, exception)
    end

  end
end

# frozen_string_literal: true

module Talkbird
  # Encapsulation of the SendBird API responses.
  module Result

    # Select the right result type based on the response.
    def self.create(response)
      status_code = response.code

      if 200 <= status_code && status_code < 400
        ary = paginate_result(response)
        ary.reduce({}) { |data, el| data.merge(el.body) }
      else
        Result::Failure.new(response)
      end
    rescue StandardError => exception
      Result::Exception.new(response, exception)
    end

    def self.paginate_result(response)
      body = MultiJson.load(response.body.to_s, symbolize_keys: true)
      token = body[:next].to_s

      if !token.empty?
        [
          Result::Success.new(response),
          Talkbird::Client.request(
            :get,
            response.uri,
            params: { token: token, limit: 100 }
          )
        ].flatten
      else
        [Result::Success.new(response)]
      end
    end

  end
end

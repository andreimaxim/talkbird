# frozen_string_literal: true

module Talkbird
  module Result
    # A variation of the result which should support composition.
    class PaginatedSuccess

      class << self

        def deep_merge(data, elem)
          data.merge(elem) do |key, oldval, newval|
            if key == :next
              nil
            else
              oldval + newval
            end
          end
        end

      end

      def initialize(result)
        @result = result
      end

      def reduce
        body = compose.reduce({}) { |data, el| PaginatedSuccess.deep_merge(data, el.body) }
        response = HTTP::Response.new(
          status: @result.status,
          version: @result.version,
          body: MultiJson.dump(body),
          headers: @result.headers
        )

        Result::Success.new(response, body)
      end

      def compose
        body = MultiJson.load(@result.body.to_s, symbolize_keys: true)
        token = body[:next].to_s

        if !token.empty?
          [
            Result::Success.new(@result, body),
            next_page(token)
          ].flatten
        else
          [Result::Success.new(@result, body)]
        end
      end

      def next_page(token)
        Talkbird::Client.request(
          :get,
          @result.uri,
          params: { token: token, limit: 100 }
        )
      end

    end
  end
end

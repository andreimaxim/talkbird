# frozen_string_literal: true

module Talkbird
  module Instrumentation
    # General instrumentation event for an ActiveSupport
    # notification.
    class Event

      START_EVENT = 'start_request.sendbird'
      END_EVENT = 'request.sendbird'

      class << self

        def debug?
          ENV.key?('SENDBIRD_DEBUG')
        end

        def normalized_request_data(payload)
          data = payload[:request]

          hsh = {
            type: 'request',
            method: data.verb.upcase,
            url: anonymize_app_id_from_url(data.uri)
          }

          hsh[:body] = data.body if Event.debug?
          hsh
        end

        def normalized_response_data(payload)
          data = payload[:response]

          hsh = {
            type: 'response',
            code: data.status,
            url: anonymize_app_id_from_url(data.uri)
          }

          hsh[:body] = data.body if Event.debug?
          hsh
        end

        def anonymize_app_id_from_url(url)
          app_id = Talkbird::Client.application_id.downcase

          url.to_s.gsub(app_id, '...')
        end

      end

      # Array of expected params:
      # * name
      # * start_time
      # * finish_time
      # * id of the event
      # * payload (simple hash with either :request or :response)
      def initialize(params)
        @name = params[0]
        @start_time = params[1]
        @finish_time = params[2]
        @id = params[3]
        @payload = params[4]
      end

      def normalized_payload
        if @name == START_EVENT
          Event.normalized_request_data(@payload)
        elsif @name == END_EVENT
          Event.normalized_response_data(@payload)
        else
          {}
        end
      end

      def to_h
        data = normalized_payload

        {
          id: @id
        }.merge(data)
      end

      def to_s
        to_h.map { |name, val| "#{name}=#{val}" }.join(' ')
      end

    end
  end
end

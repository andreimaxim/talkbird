# frozen_string_literal: true

module Talkbird
  # Class that handles the basic calls to SendBird
  class Client

    VERSION = 3

    include Singleton

    class << self

      def token
        token = ENV['SENDBIRD_API_TOKEN'].to_s

        if token.empty?
          raise ArgumentError, 'Missing SendBird API token from ENV'
        else
          token
        end
      end

      def application_id
        app_id = ENV['SENDBIRD_APP_ID'].to_s

        if app_id.empty?
          raise ArgumentError, 'Missing SendBird application ID from ENV'
        else
          app_id
        end
      end

      def base_url
        "https://api-#{application_id}.sendbird.com"
      end

      def version
        "v#{VERSION}"
      end

      def full_path(path)
        Addressable::URI.parse([base_url, Client.version, path].join('/'))
      end

      def request(method, path, opts = {})
        response = Client.instance.request(method, path, opts)
        status_code = response.code

        if 200 <= status_code && status_code < 400
          Result::Success.new(response)
        else
          Result::Failure.new(response)
        end
      rescue StandardError => exception
        Result::Exception.new(response, exception)
      end

    end

    def initialize
      @http = HTTP.use(
        instrumentation: {
          instrumenter: ActiveSupport::Notifications.instrumenter,
          namespace: 'sendbird'
        }
      )

      register_instrumentation_for_request
      register_instrumentation_for_response
    end

    def request(method, path, opts = {})
      default_headers = {
        'Api-Token' => Client.token,
        'Content-Type' => 'application/json, charset=utf8'
      }

      @http.request(
        method,
        Client.full_path(path),
        opts.merge(headers: default_headers)
      )
    end

    private

    def register_instrumentation_for_request
      event_name = Talkbird::Instrumentation::Event::START_EVENT

      ActiveSupport::Notifications.subscribe(event_name) do |*params|
        data = Talkbird::Instrumentation::Event.new(params)
        puts data
      end
    end

    def register_instrumentation_for_response
      event_name = Talkbird::Instrumentation::Event::END_EVENT

      ActiveSupport::Notifications.subscribe(event_name) do |*params|
        data = Talkbird::Instrumentation::Event.new(params)
        puts data
      end
    end

  end
end

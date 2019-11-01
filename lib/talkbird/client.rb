# frozen_string_literal: true

module Talkbird
  # Class that handles the basic calls to SendBird
  class Client

    VERSION = 'v3'
    SCHEME = 'https'

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

      def host
        "api-#{application_id}.sendbird.com"
      end

      def uri(path, params = {})
        if path.is_a?(HTTP::URI)
          build_uri_from_existing(path, params)
        else
          build_uri_from_partial_path(path, params)
        end
      end

      def request(method, path, opts = {})
        default_headers = {
          'Api-Token' => token,
          'Content-Type' => 'application/json, charset=utf8'
        }

        req = HTTP::Request.new(
          verb: method,
          uri: uri(path, opts[:params]),
          headers: (opts[:headers] || {}).merge(default_headers)
        )

        req[:body] = opts[:body] if opts.key?(:body)

        response = Client.instance.request(req, opts)
        Talkbird::Result.create(response)
      end

      private

      def build_uri_from_existing(path, params = {})
        uri = Addressable::URI.parse(path)
        extra_params = (params || {})
                         .transform_keys { |key| key.to_s.downcase }
        opts = {
          scheme: uri.scheme,
          host: uri.host,
          path: uri.path
        }

        # Remove the token from the existing query as it is most likely invalid
        # anyway.
        query = (uri.query_values || {}).reject { |name, _val| name == 'token' }

        opts[:query_values] = if query.empty? && extra_params.empty?
                                nil
                              else
                                query.merge(extra_params)
                              end

        Addressable::URI.new(opts)
      end

      def build_uri_from_partial_path(partial_path, params = {})
        path = [Client::VERSION, partial_path].join('/')
        opts = {
          scheme: Client::SCHEME,
          host: Client.host,
          path: path
        }

        # Adding the `query_values` when the `params` is an empty hash
        # will add a `?` at the end of the URL.
        opts[:query_values] = params if params && !params.empty?

        Addressable::URI.new(opts)
      end

    end

    def initialize
      @http = HTTP.use(
        instrumentation: {
          instrumenter: ActiveSupport::Notifications.instrumenter,
          namespace: Talkbird::Instrumentation::Event::NAMESPACE
        }
      )

      Instrumentation::Event.register_instrumentation_for_request
      Instrumentation::Event.register_instrumentation_for_response
    end

    def request(req, opts = {})
      options = HTTP::Options.new(opts)
      @http.perform(req, options)
    end

  end
end

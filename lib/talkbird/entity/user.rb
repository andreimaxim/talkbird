# frozen_string_literal: true

module Talkbird
  module Entity
    # A SendBird User entity.
    #
    # Users can chat with each other by participanting in open channels and
    # joining group channels. They are identified by their own unique ID,
    # and may have a customized nickname and profile image.
    #
    # Various attributes of each user, as well as their actions can be
    # managed through the API.
    class User

      DEFAULTS = {
        nickname: '',
        profile_url: '',
        issue_session_token: true
      }.freeze

      class << self

        # Find a user with a specific ID.
        #
        # @param id [String] The user's unique ID
        # @return [User, Boolean]
        def find(id)
          result = Client.request(:get, "users/#{id}")

          if result.is_a?(Result::Success)
            User.new(result.body)
          else
            false
          end
        end

        def create(id, opts = {})
          body = DEFAULTS.merge(opts)
          result = Client.request(:post, 'users', body: body)

          if result.is_a?(Result::Success)
            User.new(result.body)
          else
            false
          end
        end

        def find_or_create(id, opts = {})
          if id.is_a?(Entity::User)
            id
          else
            User.find(id) || User.create(id, opts)
          end
        end

        # Find all the users in the application.
        #
        # WARNING: This may take a lot of time.
        def all
          result = Client.request(:get, 'users')

          if result.is_a?(Result::Success)
            result.body[:users].map { |data| User.new(data) }
          else
            []
          end
        end

      end

      def initialize(data = {})
        @data = data
      end

      ## Basic user properties
      #
      # The unique ID of the user
      def id
        @data[:user_id]
      end

      # The user's nickname.
      def nickname
        @data[:nickname]
      end

      # The URL of the user's profile image.
      def profile_url
        @data[:profile_url]
      end

      # An opaque string that identifies the user.
      #
      # It is recommended that every user has their own access token and
      # provides it uopn login for security.
      def access_token
        @data[:access_token]
      end

      # An array of inforation of session tokens that identifies the user
      # session and which have no validity after their own expiration time.
      #
      # Each of items consists of two `session_token` and `expires_at`
      # properties. The `session_token` is an opaque string and `expires_at`
      # is a validation period of the session token.
      #
      # It is recommended that a new session token is periodically isseud to
      # every user, and provided upon the user's login for security.
      def session_tokens
        @data[:session_tokens]
      end

      # Indicates if the user has ever logged into the application so far.
      def ever_logged_in?
        @data[:has_ever_logged_in]
      end

      # Indicates whether the user is currently active within the application.
      def active?
        @data[:active]
      end

      # Indicates whether the user is currently connected to a SendBird server.
      def online?
        @data[:online]
      end

      # An array of unique identifies of the user which are used as discovering
      # keys when searching and adding friends.
      def discovery_keys
        @data[:discovery_keys]
      end

      # The time recoreded when the user goes offline, to indicate when they
      # were last seen online, in Unix miliseconds format.
      #
      # If the user is online, the value is set to 0.
      def last_seen_at
        @data[:last_seen_at]
      end

      # An array of key-value pair items which store additional user
      # information.
      def metadata
        @data[:metadata]
      end

      # Send a message to a user
      #
      # @param to [String] The Sendbird user ID that should receive the message
      # @param text [String] The message body
      #
      # @return [Boolean]
      def message(to, text)
        Entity::Message.new(self, to, text).deliver
      end

      def to_h
        @data.to_h
      end

      def to_s
        "#<Talkbird::Entity::User:#{id} active=#{active?} online=#{online?}>"
      end

    end
  end
end

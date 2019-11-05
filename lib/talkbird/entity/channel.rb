# frozen_string_literal: true

module Talkbird
  module Entity
    # SendBird channel
    class Channel

      DEFAULTS = {
        distinct: true,
        is_ephemeral: true
      }.freeze

      class << self

        def find(from, to)
          # The only way to find a conversation with another person is to search
          # through all the conversations with some rather strict parameters
          # and pick the best match.
          #
          # In this case, the order is based on the latest last message as it
          # makes more sense to have the
          result = Client.request(
            :get,
            "users/#{from}/my_group_channels",
            params: {
              members_exactly_in: to,
              order: 'latest_last_message',
              distinct_mode: 'distinct',
              public_mode: 'private',
              show_member: true,
              limit: 1
            }
          )

          # Since this is the result of a search, the response can be an empty
          # array, in which case the result should also be false.
          if result.is_a?(Result::Success) && !result.body[:channels].empty?
            Channel.build(result.body[:channels].first)
          else
            false
          end
        end

        # Build a channel based on the current payload.
        #
        # @return [Channel, Boolean]
        def build(payload)
          !payload.empty? && Channel.new(payload)
        end

        def create(from, to, opts = {})
          body = DEFAULTS.merge(opts)

          body[:channel_url] = opts.fetch(:id) { SecureRandom.uuid }
          body[:user_ids] = [from, to]

          result = Client.request(
            :post,
            'group_channels',
            body: body
          )

          if result.is_a?(Result::Success)
            Channel.new(result.body)
          else
            false
          end
        end

        def find_or_create(from, to)
          Channel.find(from, to) || Channel.create(from, to)
        end

      end

      def initialize(data = {})
        @data = data
      end

      def id
        @data[:channel_url]
      end

      def name
        @data[:name]
      end

      def members
        @data[:members].map { |hsh| Entity::User.new(hsh) }
      end

      def update(message)
        body = {
          user_id: message.sender.id,
          message: message.body,
          message_type: 'MESG',
        }

        Client.request(
          :post,
          "group_channels/#{id}/messages",
          body: body
        )
      end

      def to_s
        "#<Talkbird::Entity::Channel id=#{id} name=#>"
      end

    end
  end
end

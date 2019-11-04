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

          if result.is_a?(Result::Success)
            Channel.new(result.body[:channels].first)
          else
            false
          end
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

      def update(message)
        body = {
          user_id: message.sender.id,
          message: message.body,
          message_type: 'MESG',
        }

        result = Client.request(
          :post,
          "group_channels/#{id}/messages",
          body: body
        )

        if result.is_a?(Result::Success)
          Entity::Message.build(result.body)
        else
          false
        end
      end

    end
  end
end

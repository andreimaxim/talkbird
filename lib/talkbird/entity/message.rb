# frozen_string_literal: true

module Talkbird
  module Entity
    # SendBird message
    class Message

      attr_reader :sender
      attr_reader :receiver
      attr_reader :body

      class << self

        def build(response)
          response
        end

      end

      def initialize(from, to, body)
        @sender = User.find_or_create(from)
        @receiver = User.find_or_create(to)
        @body = body
      end

      def deliver
        return false if !sender || !receiver

        channel = Entity::Channel.find_or_create(sender.id, receiver.id)
        puts channel.inspect
        channel.update(self)
      end

    end
  end
end

# frozen_string_literal: true

module Talkbird
  module Entity
    # SendBird message
    class Message

      attr_reader :sender
      attr_reader :receiver
      attr_reader :body

      DEFAULTS = {
        type: 'MESG'
      }.freeze

      class << self

        def build(response)
          response
        end

      end

      def initialize(from, to, body, options = {})
        @sender = User.find_or_create(from)
        @receiver = User.find_or_create(to)
        @body = body

        @options = options
      end

      def deliver
        return false if !sender || !receiver

        channel = Entity::Channel.find_or_create(sender.id, receiver.id)
        channel.update(self)
      end

      def to_h
        options.merge(
          user_id: sender.id,
          message: body
        )
      end

      def options
        DEFAULTS.merge(@options)
      end

    end
  end
end

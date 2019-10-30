# frozen_string_literal: true

require 'singleton'
require 'addressable'
require 'http'
require 'multi_json'
require 'active_support/notifications'

require 'talkbird/version'
require 'talkbird/client'

require 'talkbird/result/basic'
require 'talkbird/result/success'
require 'talkbird/result/failure'
require 'talkbird/result/exception'

require 'talkbird/instrumentation/event'

# Unofficial SendBird API client.
module Talkbird
end

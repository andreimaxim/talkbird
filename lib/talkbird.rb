# frozen_string_literal: true

require 'singleton'
require 'addressable'
require 'http'
require 'multi_json'
require 'active_support/notifications'

require 'talkbird/version'
require 'talkbird/client'

require 'talkbird/result'
require 'talkbird/result/basic'
require 'talkbird/result/success'
require 'talkbird/result/paginated_success'
require 'talkbird/result/failure'
require 'talkbird/result/exception'

require 'talkbird/instrumentation/event'

require 'talkbird/entity/channel'
require 'talkbird/entity/message'
require 'talkbird/entity/user'

# Unofficial SendBird API client.
module Talkbird
end

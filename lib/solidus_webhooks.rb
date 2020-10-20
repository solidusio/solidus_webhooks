# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

require 'solidus_webhooks/configuration'
require 'solidus_webhooks/version'
require 'solidus_webhooks/engine'

module SolidusWebhooks
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def reset_config!
      @configuration = nil
    end

    def configure
      yield configuration
    end
  end
end

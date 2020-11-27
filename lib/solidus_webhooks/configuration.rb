# frozen_string_literal: true

require 'solidus_webhooks/errors'

module SolidusWebhooks
  class Configuration
    def initialize
      @handlers = {}
    end

    def register_webhook_handler(id, handler)
      unless handler.respond_to? :call
        raise SolidusWebhooks::InvalidHandler,
          "Please provide a handler that responds to #call, got: #{handler.inspect}"
      end

      @handlers[id.to_sym] = handler
    end

    def find_webhook_handler(id)
      @handlers[id.to_sym]
    end
  end

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

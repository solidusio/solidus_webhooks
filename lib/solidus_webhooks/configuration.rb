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

  def self.config
    @config
  end

  def self.reset_config!
    @config = Configuration.new
  end

  reset_config! # initialize the extension
end

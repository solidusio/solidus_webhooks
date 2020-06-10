class Spree::Webhook
  include ActiveModel::Model
  attr_accessor :handler, :id

  WebhookNotFound = Class.new(StandardError)

  def receive(payload, user)
    if handler_arity == 1
      handler.call(payload)
    else
      handler.call(payload, user)
    end
  end

  def self.find(id)
    id = id.to_sym # normalize incoming ids

    handler = SolidusWebhooks.config.find_webhook_handler(id) or
      raise WebhookNotFound, "Cannot find a webhook handler for #{id.inspect}"

    new(id: id, handler: handler)
  end

  private

  def handler_arity
    if handler.respond_to?(:arity)
      handler.arity
    else
      handler.method(:call).arity
    end
  end
end

class Spree::Webhook
  include ActiveModel::Model
  attr_accessor :handler, :id

  WebhookNotFound = Class.new(StandardError)

  def receive(payload)
    handler.call(payload)
  end

  def self.find(id)
    id = id.to_sym # normalize incoming ids

    handler = SolidusWebhooks.config.find_webhook_handler(id) or
      raise WebhookNotFound, "Cannot find a webhook handler for #{id.inspect}"

    new(id: id, handler: handler)
  end
end

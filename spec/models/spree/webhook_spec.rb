require 'spec_helper'

RSpec.describe Spree::Webhook do
  describe '.find' do
    before { SolidusWebhooks.config.register_webhook_handler :foo, ->(payload) {} }

    it 'can find a registered handler' do
      expect(described_class.find(:foo)).to be_a(described_class)
      expect{described_class.find(:bar)}.to raise_error(SolidusWebhooks::WebhookNotFound)
    end
  end
end

require 'spec_helper'

RSpec.feature "Can register a handler and receive Webhooks", type: :request do
  background do
    SolidusWebhooks.reset_config!
    SolidusWebhooks.config.register_webhook_handler :foo, foo_handler
    SolidusWebhooks.config.register_webhook_handler :bar, bar_handler
  end

  let(:foo_payloads) { [] }
  let(:bar_payloads) { [] }

  let(:foo_handler) { ->(payload, current_api_user) { foo_payloads << payload } }
  let(:bar_handler) { ->(payload, current_api_user) { bar_payloads << payload } }

  let(:token) { create(:admin_user, spree_api_key: "123").spree_api_key }
  let(:token_without_permission) { create(:user, spree_api_key: "456").spree_api_key }

  scenario "calls the handler passing the payload" do
    post "/webhooks/foo?token=#{token}", as: :json, params: {a: 123}
    expect(response).to have_http_status(:ok)

    post "/webhooks/foo?token=#{token}", as: :json, params: {b: 456}
    expect(response).to have_http_status(:ok)

    post "/webhooks/bar?token=#{token}", as: :json, params: {c: 789}
    expect(response).to have_http_status(:ok)

    expect(foo_payloads).to eq([{'a' => 123}, {'b' => 456}])
    expect(bar_payloads).to eq([{'c' => 789}])
  end

  scenario "receives a bad handler id" do
    post "/webhooks/baz?token=#{token}", as: :json, params: {a: 123}
    expect(response).to have_http_status(:not_found)
  end

  scenario "refuses a bad token" do
    post "/webhooks/baz?token=b4d-t0k3n", as: :json, params: {a: 123}
    expect(response).to have_http_status(:unauthorized)
  end

  scenario "refuses a token without permissions" do
    post "/webhooks/foo?token=#{token_without_permission}", as: :json, params: {a: 123}
    expect(response).to have_http_status(:unauthorized)
  end
end

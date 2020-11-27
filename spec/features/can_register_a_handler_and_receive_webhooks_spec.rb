require 'spec_helper'

RSpec.feature "Can register a handler and receive Webhooks", type: :request do
  background do
    SolidusWebhooks.config.register_webhook_handler :proc, proc_handler
    SolidusWebhooks.config.register_webhook_handler :method, method_handler
    SolidusWebhooks.config.register_webhook_handler :user, user_handler
    SolidusWebhooks.config.register_webhook_handler :splat, splat_handler
    SolidusWebhooks.config.register_webhook_handler :method_and_user, method_and_user_handler
  end

  let(:proc_payloads) { [] }
  let(:method_payloads) { [] }
  let(:user_payloads) { [] }
  let(:splat_payloads) { [] }
  let(:method_and_user_payloads) { [] }

  let(:proc_handler) { ->(payload) { proc_payloads << payload } }
  let(:method_handler) {
    Struct.new(:payloads) { def call(payload) payloads << payload end }.new(method_payloads)
  }
  let(:user_handler) { ->(payload, user) { user_payloads << [payload, user] } }
  let(:splat_handler) { ->(*args) { splat_payloads << args } }
  let(:method_and_user_handler) {
    Struct.new(:payloads) { def call(payload, user) payloads << [payload, user] end }.new(method_and_user_payloads)
  }

  let(:authorized_user) { create(:admin_user, spree_api_key: "123") }
  let(:authorized_token) { authorized_user.spree_api_key }

  let(:unauthorized_user) { create(:user, spree_api_key: "456") }
  let(:unauthorized_token) { unauthorized_user.spree_api_key }

  scenario "calls the handler passing the payload" do
    post "/webhooks/proc?token=#{authorized_token}", as: :json, params: { a: 123 }
    expect(response).to have_http_status(:ok)

    post "/webhooks/proc?token=#{authorized_token}", as: :json, params: { b: 456 }
    expect(response).to have_http_status(:ok)

    post "/webhooks/method?token=#{authorized_token}", as: :json, params: { c: 789 }
    expect(response).to have_http_status(:ok)

    post "/webhooks/user?token=#{authorized_token}", as: :json, params: { d: 12 }
    expect(response).to have_http_status(:ok)

    post "/webhooks/splat?token=#{authorized_token}", as: :json, params: { e: 345 }
    expect(response).to have_http_status(:ok)

    post "/webhooks/method_and_user?token=#{authorized_token}", as: :json, params: { f: 678 }
    expect(response).to have_http_status(:ok)

    expect(proc_payloads).to eq([{ 'a' => 123 }, { 'b' => 456 }])
    expect(method_payloads).to eq([{ 'c' => 789 }])
    expect(user_payloads).to eq([[{ 'd' => 12 }, authorized_user]])
    expect(splat_payloads).to eq([[{ 'e' => 345 }, authorized_user]])
    expect(method_and_user_payloads).to eq([{ 'f' => 678 }, authorized_user])
  end

  scenario "receives a bad handler id" do
    post "/webhooks/abc?token=#{authorized_token}", as: :json, params: { a: 123 }
    expect(response).to have_http_status(:not_found)
  end

  scenario "refuses a bad token" do
    post "/webhooks/user?token=b4d-t0k3n", as: :json, params: { a: 123 }
    expect(response).to have_http_status(:unauthorized)
  end

  scenario "refuses a token without permissions" do
    post "/webhooks/proc?token=#{unauthorized_token}", as: :json, params: { a: 123 }
    expect(response).to have_http_status(:unauthorized)
  end
end

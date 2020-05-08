# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  post '/webhooks/:id', to: 'webhooks#receive', as: :receive_webhook
end

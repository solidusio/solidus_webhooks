class Spree::WebhooksController < Spree::Api::BaseController
  rescue_from(Spree::Webhook::WebhookNotFound) { head :not_found }

  def receive
    webhook = Spree::Webhook.find(params[:id])
    payload = request.request_parameters["webhook"]
    user = current_api_user

    authorize! :receive, webhook

    webhook.receive(payload, user)

    head :ok
  end
end

class Spree::WebhooksController < Spree::Api::BaseController
  rescue_from(Spree::Webhook::WebhookNotFound) { head :not_found }

  def receive
    webhook = Spree::Webhook.find(params[:id])
    payload = request.request_parameters["webhook"]

    authorize! :receive, webhook

    webhook.receive(payload)

    head :ok
  end
end

class Mno::RecipientsController < Mno::BaseController
  def index
    @recipients = Recipient.where(mobile_network_id: @mobile_network.id)
  end
end

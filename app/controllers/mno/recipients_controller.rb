class Mno::RecipientsController < Mno::BaseController
  def index
    @recipients = Recipient.where(mobile_network_id: @mobile_network.id)
    @recipients_form = RecipientsForm.new(recipients: @recipients)
  end
end

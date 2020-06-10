class Mno::RecipientsController < Mno::BaseController
  def index
    @recipients = Recipient.where(mobile_network_id: @mobile_network.id)
    @recipients_form = Mno::RecipientsForm.new(recipients: @recipients)
  end

  def report_problem
  end
end

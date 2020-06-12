class Mno::RecipientsController < Mno::BaseController
  def index
    @recipients = Recipient.where(mobile_network_id: @mobile_network.id)
    @recipients_form = Mno::RecipientsForm.new(
        recipients: @recipients,
        recipient_ids: selected_recipient_ids(@recipients, params)
    )
    @statusses = ['Complete', 'In progress']
  end

  def report_problem
  end

private

  def selected_recipient_ids(recipients, opts = params)
    if params[:select] == 'all'
      recipients.pluck(:id)
    elsif params[:select] == 'none'
      []
    else
      params[:recipient_ids]
    end
  end
end

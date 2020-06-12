class Mno::RecipientsController < Mno::BaseController
  def index
    @recipients = Recipient.where(mobile_network_id: @mobile_network.id)
    @recipients_form = Mno::RecipientsForm.new(
        recipients: @recipients,
        recipient_ids: selected_recipient_ids(@recipients, params)
    )
    @statuses = Recipient.translated_enum_values( :statuses )
  end

  def report_problem
  end

  def bulk_update
    Recipient.transaction do |t|
      Recipient.where('id IN (?)', bulk_update_params[:recipient_ids].reject(&:empty?))
               .update_all(status: bulk_update_params[:status])

      redirect_to mno_recipients_path
      rescue ActiveRecord::StatementInvalid
        flash[:error] = "I couldn't apply that update"
        raise ActiveRecord::Rollback
    end
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

  def bulk_update_params(opts = params)
    opts.require(:mno_recipients_form).permit(
      :status,
      recipient_ids: [],
    )
  end
end

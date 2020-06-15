class Mno::RecipientsController < Mno::BaseController
  def index
    @pagination, @recipients = pagy(
      Recipient.where(mobile_network_id: @mobile_network.id)
               .order(safe_order),

    )
    @recipients_form = Mno::RecipientsForm.new(
      recipients: @recipients,
      recipient_ids: selected_recipient_ids(@recipients, params),
    )
    @statuses = Recipient.translated_enum_values(:statuses)
  end

  def report_problem; end

  def bulk_update
    Recipient.transaction do
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
    if opts[:select] == 'all'
      recipients.pluck(:id)
    elsif opts[:select] == 'none'
      []
    else
      opts[:recipient_ids]
    end
  end

  def bulk_update_params(opts = params)
    opts.require(:mno_recipients_form).permit(
      :status,
      recipient_ids: [],
    )
  end

  def safe_order(opts = params)
    order = db_order_field(opts[:sort])
    if order
      {order => db_dir(opts[:dir])}
    end
  end

  def db_dir(dir_param)
    dir_param == 'd' ? :desc : :asc
  end

  def db_order_field(order_param)
    {
      'id' => :id,
      'mobile_number' => :device_phone_number,
      'full_name' => :full_name,
      'requested' => :created_at,
      'status' => :status,
    }[order_param]
  end
end

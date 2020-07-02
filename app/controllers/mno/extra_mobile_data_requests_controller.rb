class Mno::ExtraMobileDataRequestsController < Mno::BaseController
  def index
    @recipients = ExtraMobileDataRequest.from_approved_users
                                        .on_mobile_network(@user.mobile_network_id)
                                        .order(safe_order)

    respond_to do |format|
      format.csv do
        render csv: @recipients, filename: "requests-mno-#{@mobile_network.id}-#{Time.now.iso8601}.csv"
      end
      # capybara sends through NullType sometimes
      format.any do
        @pagination, @recipients = pagy(@recipients)
        @recipients_form = Mno::ExtraMobileDataRequestsForm.new(
          recipients: @recipients,
          recipient_ids: selected_recipient_ids(@recipients, params),
        )
        @statuses = ExtraMobileDataRequest.translated_enum_values(:statuses).reject { |status| status.value == 'queried' }
      end
    end
  end

  def report_problem; end

  def bulk_update
    ExtraMobileDataRequest.transaction do
      ExtraMobileDataRequest.from_approved_users
               .on_mobile_network(@user.mobile_network_id)
               .where('recipients.id IN (?)', bulk_update_params[:recipient_ids].reject(&:empty?))
               .update_all(status: bulk_update_params[:status])
      redirect_to mno_recipients_path
    rescue ActiveRecord::StatementInvalid, ArgumentError => e
      logger.error e
      flash[:error] = "I couldn't apply that update"
      render :index, status: :unprocessable_entity
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
      { order => db_dir(opts[:dir]) }
    end
  end

  def db_dir(dir_param)
    dir_param == 'd' ? :desc : :asc
  end

  def db_order_field(order_param)
    {
      'id' => :id,
      'mobile_number' => :device_phone_number,
      'account_holder_name' => :account_holder_name,
      'requested' => :created_at,
      'status' => :status,
    }[order_param]
  end
end

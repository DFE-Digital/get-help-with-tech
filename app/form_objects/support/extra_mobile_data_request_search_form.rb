class Support::ExtraMobileDataRequestSearchForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :request_id, :school_id, :rb_id, :mno_id, :status

  def initialize(params = {})
    @request_id = params[:request_id]
    @school_id = params[:school_id]
    @rb_id = params[:rb_id]
    @mno_id = params[:mno_id]
    @status = params[:status]
  end

  def requests(current_user)
    requests = ExtraMobileDataRequestPolicy::Scope.new(current_user, ExtraMobileDataRequest).resolve
    requests = requests.includes(:school).includes(:responsible_body).includes(:mobile_network)
    requests = requests.where(school_id: @school_id) if @school_id.present?
    requests = requests.where(responsible_body_id: @rb_id) if @rb_id.present?
    requests = requests.where(mobile_network_id: @mno_id) if @mno_id.present?
    requests = requests.where(status: @status) if @status.present?
    requests
  end
end

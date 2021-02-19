class Support::ExtraMobileDataRequestSearchForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :request_id, :school_id, :urn_or_ukprn, :rb_id, :mno_id, :status

  def initialize(params = {})
    @request_id = params[:request_id]
    @school_id = params[:school_id]
    @urn_or_ukprn = params[:urn_or_ukprn]
    @rb_id = params[:rb_id]
    @mno_id = params[:mno_id]
    @status = params[:status]
  end

  def requests(current_user)
    requests = ExtraMobileDataRequestPolicy::Scope.new(current_user, ExtraMobileDataRequest).resolve
    requests = requests.includes(:school).includes(:responsible_body).includes(:mobile_network)
    requests = requests.where(id: @request_id) if @request_id.present?
    requests = requests.where(school_id: @school_id) if @school_id.present?
    requests = requests.joins(:school).where('schools.urn = ? OR schools.ukprn = ?', @urn_or_ukprn, @urn_or_ukprn) if @urn_or_ukprn.present?
    requests = requests.where(responsible_body_id: @rb_id) if @rb_id.present?
    requests = requests.where(mobile_network_id: @mno_id) if @mno_id.present?
    requests = requests.where(status: @status) if @status.present?
    requests
  end

  def select_responsible_body_options
    ResponsibleBody.order(:name).pluck(:id, :name).map { |id, name|
      OpenStruct.new(id: id, name: name)
    }.prepend(OpenStruct.new(id: nil, name: '(all)'))
  end

  def mobile_network_options
    MobileNetwork.where(id: ExtraMobileDataRequest.distinct(:mobile_network_id).pluck(:mobile_network_id)).map { |mno|
      OpenStruct.new(value: mno.id, label: mno.brand)
    }.prepend(OpenStruct.new(value: nil, label: '(all)'))
  end

  def status_options
    ExtraMobileDataRequest.statuses
                          .keys
                          .map { |k| OpenStruct.new(value: k, label: I18n.t(:dropdown_label, scope: [:activerecord, :attributes, :extra_mobile_data_request, :status, k])) }
                          .prepend(OpenStruct.new(value: nil, label: '(all)'))
  end
end

class Mno::ExtraMobileDataRequestsForm
  include ActiveModel::Model

  attr_accessor :extra_mobile_data_requests, :extra_mobile_data_request_ids, :status

  def extra_mobile_data_requests_for_collection_select
    @extra_mobile_data_requests.map do |r|
      OpenStruct.new(id: r.id, label: '')
    end
  end
end

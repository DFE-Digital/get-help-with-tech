class ExtraMobileDataRequestSummaryListComponent < ViewComponent::Base
  validates :extra_mobile_data_request, presence: true

  def initialize(extra_mobile_data_request:)
    @extra_mobile_data_request = extra_mobile_data_request
  end

  def rows
    [
      {
        key: 'Request ID',
        value: @extra_mobile_data_request.id,
      },
      {
        key: 'Requested on',
        value: @extra_mobile_data_request.created_at.to_s(:govuk_date_and_time),
      },
      {
        key: 'Account holder',
        value: @extra_mobile_data_request.account_holder_name,
      },
      {
        key: 'Mobile number',
        value: @extra_mobile_data_request.device_phone_number,
      },
      {
        key: 'Mobile network',
        value: @extra_mobile_data_request.mobile_network.brand,
      },
      {
        key: 'Pay Monthly or Pay-as-you-go',
        value: I18n.t(@extra_mobile_data_request.contract_type, scope: %i[activerecord attributes extra_mobile_data_request contract_types]),
      },
    ]
  end
end

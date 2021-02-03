class ExtraMobileDataRequestStatusDetailsComponent < ViewComponent::Base
  validates :extra_mobile_data_request, presence: true

  def initialize(extra_mobile_data_request:, context: :school)
    @extra_mobile_data_request = extra_mobile_data_request
  end
end

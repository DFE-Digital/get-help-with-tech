class ExtraMobileDataRequestStatusDetailsComponent < ViewComponent::Base
  attr_accessor :extra_mobile_data_request, :context

  validates :extra_mobile_data_request, presence: true

  def initialize(extra_mobile_data_request:, context: :school)
    @extra_mobile_data_request = extra_mobile_data_request
    @context = context
  end
end

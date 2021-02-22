class Support::ExtraMobileDataRequestComponent < ViewComponent::Base
  attr_accessor :request

  def initialize(request)
    @request = request
  end

  def link_to_requester
    if request.school_id.present?
      govuk_link_to "#{request.school.name} (#{request.school.urn})", support_school_path(urn: request.school.urn)
    else
      govuk_link_to request.responsible_body.name, support_responsible_body_path(request.responsible_body_id)
    end
  end
end

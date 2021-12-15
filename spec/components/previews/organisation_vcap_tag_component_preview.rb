class OrganisationVcapTagComponentPreview < ViewComponent::Preview
  STATUS = [true, false].freeze

  STATUS.each do |status|
    define_method("vcap_#{status}") do
      organisation = OpenStruct.new(vcap?: status)
      render(OrganisationVcapTagComponent.new(organisation))
    end
  end
end

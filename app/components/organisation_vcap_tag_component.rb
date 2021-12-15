class OrganisationVcapTagComponent < ViewComponent::Base
  validates :organisation, presence: true

  def initialize(organisation)
    @organisation = organisation
  end

  def text
    I18n.t!(vcap?, scope: %i[components organisation_vcap_tag_component vcap])
  end

  def color
    vcap? ? :green : :yellow
  end

private

  attr_reader :organisation

  delegate :vcap?, to: :organisation
end

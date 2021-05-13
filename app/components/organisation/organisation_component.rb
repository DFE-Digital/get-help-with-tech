# frozen_string_literal: true

class Organisation::OrganisationComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
    @link_text = if organisation.is_a?(LocalAuthority)
                   "#{organisation.name} &ndash; state schools and colleges"
                 elsif organisation.independent_special_school?
                   "#{organisation.responsible_body.name} &ndash; state&#8209;funded pupils at independent special schools and alternative provision"
                 elsif organisation.social_care_leaver?
                   "#{organisation.responsible_body.name} &ndash; social care leavers"
                 else
                   organisation.name
                 end
  end

  def before_render
    @link_path = case @organisation
                 when School
                   home_school_path(@organisation)
                 when ResponsibleBody
                   responsible_body_home_path(@organisation)
                 end
  end
end

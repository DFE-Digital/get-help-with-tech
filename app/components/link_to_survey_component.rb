# frozen_string_literal: true

class LinkToSurveyComponent < ViewComponent::Base
  def initialize(organisation:)
    @organisation = organisation
  end

  def render?
    @organisation.respond_to?(:la_funded_provision?) ? !@organisation.la_funded_provision? : true
  end
end

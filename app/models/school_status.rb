class SchoolStatus
  def initialize(school)
    @school = school
  end

  def status
    @status ||= status_and_actions.first
  end

  def actions
    @actions ||= status_and_actions.last
  end

private

  def status_and_actions
    if school.nil?
      [:school_not_found, [check_on_gias, ask_ghwt_service_team_to_investigate]]
    elsif !in_devices_reserve? && responsible_body.has_only_one_school?
      [:not_yet_onboarded_single_school, [ask_ghwt_service_team_to_onboard]]
    elsif !in_devices_reserve?
      [:not_yet_onboarded_other, [ask_ghwt_service_team_to_investigate]]
    elsif !responsible_body_decided_who_will_order?
      [:responsible_body_not_decided_who_will_order, [nudge_responsible_body_to_devolve_or_centralise]]
    elsif ordering_centralised?
      centralised_ordering_status_and_actions
    elsif ordering_devolved_to_schools?
      school_ordering_status_and_actions
    else
      raise 'This case should never happen'
    end
  end

  # > Order users need to sign in
  # > waiting for TS account
  # > set caps, finish school info
  # > ready to order
  # > ordered
  def centralised_ordering_status_and_actions
    if !any_responsible_body_order_users?
      [:responsible_body_users_must_sign_in, []]
    elsif !any_responsible_body_order_users_have_techsource_accounts?
      [:responsible_body_order_users_waiting_for_techsource_accounts, []]
    elsif any_responsible_body_order_users_have_techsource_accounts? && !school.can_order_devices? && !school.has_ordered_devices?
      [:waiting_for_cap_to_be_set, []]
    elsif any_responsible_body_order_users_have_techsource_accounts? && school.can_order_devices? && !school.has_ordered_devices?
      [:ready_to_order, []]
    elsif school.has_ordered_devices?
      [:ordered, []]
    end
  end

  def school_ordering_status_and_actions
    if school_status == 'needs_contact'
      [:school_needs_a_contact, [nudge_responsible_body_to_select_a_contact, link_to_school_support_page('Contact the headteacher')]]
    elsif school_status == 'school_will_be_contacted'
      [:school_needs_to_be_contacted, [link_to_responsible_body_support_page('Invite the school')]]
    elsif school_status == 'school_contacted' && !any_school_users_signed_in?
      [:school_users_inactive, [link_to_school_support_page('Nudge school users to use the service')]]
    elsif !any_school_order_users?
      [:school_users_must_sign_in, []]
    elsif !any_school_order_users_have_techsource_accounts?
      [:school_order_users_waiting_for_techsource_accounts, []]
    elsif any_school_order_users_have_techsource_accounts? && !school.can_order_devices? && !school.has_ordered_devices?
      [:waiting_for_cap_to_be_set, []]
    elsif any_school_order_users_have_techsource_accounts? && school.can_order_devices? && !school.has_ordered_devices?
      [:ready_to_order, []]
    elsif school.has_ordered_devices?
      [:ordered, []]
    end
  end

  def check_on_gias
    "Check the school details on #{school_url_on_gias}"
  end

  def ask_ghwt_service_team_to_onboard
    'SAT - ask the GHWT service team to onboard this school'
  end

  def ask_ghwt_service_team_to_investigate
    'Ask the GHWT service team to investigate why this school is not on the service'
  end

  def nudge_responsible_body_to_devolve_or_centralise
    "Nudge the #{link_to_responsible_body_support_page} to devolve or centralise ordering"
  end

  def nudge_responsible_body_to_select_a_contact
    "Nudge the #{link_to_responsible_body_support_page} to provide the school contact"
  end

  def link_to_responsible_body_support_page(link_text = 'responsible body')
    ActionController::Base.helpers.govuk_link_to link_text, Rails.application.routes.url_helpers.support_devices_responsible_body_path(responsible_body)
  end

  def link_to_school_support_page(link_text = 'school')
    ActionController::Base.helpers.govuk_link_to link_text, Rails.application.routes.url_helpers.support_devices_school_path(urn: school.urn)
  end

  def school_url_on_gias
    ActionController::Base.helpers.govuk_link_to 'Get Information About Schools',
                                                 GetInformationAboutSchools.school_public_url(urn: school.urn)
  end

  attr_reader :school

  def responsible_body
    school.responsible_body
  end

  def school_status
    school.preorder_information.status
  end

  def in_devices_reserve?
    responsible_body.in_devices_pilot
  end

  def responsible_body_decided_who_will_order?
    responsible_body.who_will_order_devices.present?
  end

  def ordering_centralised?
    responsible_body.who_will_order_devices == 'responsible_body'
  end

  def ordering_devolved_to_schools?
    responsible_body.who_will_order_devices == 'schools'
  end

  def any_responsible_body_order_users?
    responsible_body
      .users
      .select(&:relevant_to_computacenter?)
  end

  def any_school_order_users?
    school
      .users
      .select(&:relevant_to_computacenter?)
  end

  def any_school_users_signed_in?
    school.users.map(&:sign_in_count).any?(&:positive?)
  end

  def any_responsible_body_order_users_have_techsource_accounts?
    responsible_body
      .users
      .select(&:relevant_to_computacenter?)
      .any?(&:has_techsource_account?)
  end

  def any_school_order_users_have_techsource_accounts?
    school
      .users
      .select(&:relevant_to_computacenter?)
      .any?(&:has_techsource_account?)
  end
end

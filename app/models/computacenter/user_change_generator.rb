class Computacenter::UserChangeGenerator
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def generate!
    if change_needed?
      change = Computacenter::UserChange.new(consolidated_attributes)
      change.add_original_fields_from(last_change_for_user) if last_change_for_user.present?
      change.save!
      notify_computacenter_via_api if computacenter_api_configured?
      change
    end
  end

private

  def computacenter_api_configured?
    Settings.computacenter.service_now_user_import_api.endpoint.present?
  end

  def notify_computacenter_via_api
    NotifyComputacenterOfLatestChangeForUserJob.perform_later(@user.id)
  end

  def last_change_for_user
    @last_change_for_user ||= Computacenter::UserChange.latest_for_user(user)
  end

  def consolidated_attributes
    computacenter_attributes\
      .merge(meta_attributes)
      .merge(type_of_update: type_of_update)
  end

  def change_needed?
    @user&.id.present? && \
      (is_addition? || is_removal? || (is_change? && computacenter_fields_have_changed?)) && \
      (!user_has_a_school_but_no_ship_to? || user.is_a_single_school_user?)
  end

  def user_has_a_school_but_no_ship_to?
    user.user_schools.present? && cc_ship_to_number_list.blank?
  end

  def is_addition?
    user.relevant_to_computacenter? && !user.soft_deleted? && (last_change_for_user.nil? || last_change_for_user.type_of_update == 'Remove')
  end

  def is_change?
    last_change_for_user.present? && \
      user.relevant_to_computacenter? && \
      !user.destroyed? && \
      !user.soft_deleted?
  end

  def is_removal?
    (last_change_for_user.present? && last_change_for_user.type_of_update != 'Remove' && !user.relevant_to_computacenter?) || \
      (user.relevant_to_computacenter? && user.destroyed?) || \
      (user.relevant_to_computacenter? && user.soft_deleted?)
  end

  def computacenter_fields_have_changed?
    computacenter_attributes != last_change_for_user&.computacenter_attributes
  end

  def computacenter_attributes
    {
      first_name: user.first_name,
      last_name: user.last_name,
      email_address: user.email_address,
      telephone: user.telephone,
      responsible_body: user.effective_responsible_bodies.map(&:name).join('|'),
      responsible_body_urn: user.effective_responsible_bodies.map(&:computacenter_identifier).join('|'),
      cc_sold_to_number: user.effective_responsible_bodies.map(&:computacenter_reference).join('|'),
      # NOTE: we must loop round user_schools (which may be dirty) not schools (which won't be)
      school: (user.is_a_single_school_user? ? '' : user.user_schools.map { |us| us.school.name }.join('|')),
      school_urn: (user.is_a_single_school_user? ? '' : user.user_schools.map { |us| us.school.urn }.join('|')),
      cc_ship_to_number: cc_ship_to_number_list,
      cc_rb_user: user.rb_level_access,
    }
  end

  def cc_ship_to_number_list
    (user.is_a_single_school_user? ? '' : user.user_schools.map { |us| us.school.computacenter_reference }.join('|'))
  end

  def meta_attributes
    {
      user_id: user.id,
      updated_at_timestamp: Time.zone.now.utc,
      type_of_update: type_of_update,
    }
  end

  def type_of_update
    if is_addition?
      'New'
    elsif is_change?
      'Change'
    elsif is_removal?
      'Remove'
    end
  end
end

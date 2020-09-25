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
      change
    end
  end

private

  def last_change_for_user
    @last_change_for_user ||= Computacenter::UserChange.last_for(user)
  end

  def consolidated_attributes
    computacenter_attributes\
      .merge(meta_attributes)
      .merge(type_of_update: type_of_update)
  end

  def change_needed?
    is_addition? || is_removal? || (is_change? && computacenter_fields_have_changed?)
  end

  def is_addition?
    user.relevant_to_computacenter? && last_change_for_user.nil?
  end

  def is_change?
    last_change_for_user.present? && \
      user.relevant_to_computacenter? && \
      !user.destroyed?
  end

  def is_removal?
    (last_change_for_user.present? && !user.relevant_to_computacenter?) || \
      (user.relevant_to_computacenter? && user.destroyed?)
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
      responsible_body: user.effective_responsible_body&.name,
      responsible_body_urn: user.effective_responsible_body&.computacenter_identifier,
      cc_sold_to_number: user.effective_responsible_body&.computacenter_reference,
      school: (user.hybrid? ? '' : user.school&.name),
      school_urn: (user.hybrid? ? '' : user.school&.urn),
      cc_ship_to_number: (user.hybrid? ? '' : user.school&.computacenter_reference),
    }
  end

  def meta_attributes
    {
      user_id: user.id,
      updated_at_timestamp: user.updated_at,
      type_of_update: type_of_update,
    }
  end

  def type_of_update
    if is_change?
      'Change'
    elsif is_removal?
      'Remove'
    else
      'New'
    end
  end
end

class Computacenter::UserChangeGenerator
  attr_reader :version

  def initialize(version)
    @version = version
  end

  def call
    return if version.nil?

    case type_of_update
    when 'New'
      return unless after_user.relevant_to_computacenter?
    when 'Change'
      return unless after_user.relevant_to_computacenter?
    when 'Remove'
      return unless before_user.relevant_to_computacenter?
    end

    return if (version.changeset.keys & fields_to_monitor).empty?

    Computacenter::UserChange.create!(user_change_attributes)
  end

private

  def strip_hybrid_fields!(hash)
    if before_user.hybrid? || after_user.hybrid?
      hash.delete(:school)
      hash.delete(:school_urn)
      hash.delete(:cc_ship_to_number)
    end
  end

  def user_change_attributes
    hash = meta_csv_attributes.merge(current_csv_fields).merge(original_csv_fields)
    strip_hybrid_fields!(hash)
    hash
  end

  def current_csv_fields
    {
      first_name: after_user.first_name,
      last_name: after_user.last_name,
      email_address: after_user.email_address,
      telephone: after_user.telephone,
      responsible_body: after_user.effective_responsible_body&.name,
      responsible_body_urn: after_user.effective_responsible_body&.computacenter_identifier,
      cc_sold_to_number: after_user.effective_responsible_body&.computacenter_reference,
      school: after_user.school&.name,
      school_urn: after_user.school&.urn,
      cc_ship_to_number: after_user.school&.computacenter_reference,
    }
  end

  def meta_csv_attributes
    {
      user_id: version.item_id,
      updated_at_timestamp: version.created_at,
      type_of_update: type_of_update,
    }
  end

  def fields_to_diff
    %w[
      full_name
      telephone
      email_address
      responsible_body_id
      school_id
    ]
  end

  def fields_to_monitor
    %w[
      full_name
      telephone
      email_address
      responsible_body_id
      school_id
      privacy_notice_seen_at
      orders_devices
    ]
  end

  def original_attributes
    case type_of_update
    when 'New'
      {}
    when 'Change'
      original = version.changeset.transform_values(&:first).to_h
      diffable_attributes_and_values(original)
    when 'Remove'
      original = version.object_deserialized
      diffable_attributes_and_values(original)
    end
  end

  def diffable_attributes_and_values(user_hash)
    user_hash.filter { |k, _| fields_to_diff.include?(k) }.select { |_k, v| v }
  end

  def original_csv_fields
    hash = original_attributes

    expand_full_name_changes(hash)
    expand_responsible_body_changes(hash)
    expand_school_changes(hash)

    hash.transform_keys! { |k| "original_#{k}" }

    hash
  end

  def expand_full_name_changes(hash)
    if hash.key?('full_name')
      hash['first_name'] = before_user.first_name
      hash['last_name'] = before_user.last_name

      hash.delete('full_name')
    end
  end

  def expand_responsible_body_changes(hash)
    if hash.key?('responsible_body_id')
      responsible_body = ResponsibleBody.find(hash['responsible_body_id'])

      if responsible_body
        hash['responsible_body'] = responsible_body.name
        hash['responsible_body_urn'] = responsible_body.computacenter_identifier
        hash['cc_sold_to_number'] = responsible_body.computacenter_reference
      end

      hash.delete('responsible_body_id')
    end
  end

  def expand_school_changes(hash)
    if hash.key?('school_id')
      school = School.find(hash['school_id'])

      if school
        hash['school'] = school.name
        hash['school_urn'] = school.urn
        hash['cc_ship_to_number'] = school.computacenter_reference
      end

      hash.delete('school_id')
    end
  end

  def before_user
    @before_user ||= case version.event
                     when 'create'
                       User.new
                     when 'update', 'destroy'
                       User.new(version.object_deserialized)
                     end
  end

  def after_user
    @after_user ||= User.new(after_user_attributes)
  end

  def after_user_attributes
    if version.event == 'create'
      version.changeset.transform_values(&:last)
    elsif version.event == 'destroy' || version.changeset['orders_devices'] == [true, false]
      {}
    elsif version.event == 'update'
      version.object_deserialized.merge(version.changeset.transform_values(&:last))
    end
  end

  def type_of_update
    if Computacenter::UserChange.where(user_id: (before_user.id || after_user.id)).exists?
      if is_removal?
        'Remove'
      else
        'Change'
      end
    else
      'New'
    end
  end

  def is_removal?
    version.event == 'destroy' || (
      version.event == 'update' && \
      before_user.relevant_to_computacenter? && \
      !after_user.relevant_to_computacenter?
    )
  end
end

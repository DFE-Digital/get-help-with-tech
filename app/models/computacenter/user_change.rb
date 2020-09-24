module Computacenter
  class UserChange < ApplicationRecord
    self.table_name = 'computacenter_user_changes'

    CSV_ATTRIBUTES = %i[
      first_name
      last_name
      email_address
      telephone
      responsible_body
      responsible_body_urn
      cc_sold_to_number
      school
      school_urn
      cc_ship_to_number
    ]

    enum type_of_update: { New: 0, Change: 1, Remove: 2 }

    def self.read_from_version(version)
      UserChangeGenerator.new(version).call
    end

    def self.for_user(user)
      last_change_for_user = last_for(user)
      if change_needed?(user)
        change = new(consolidated_attributes_for(user))
        change.add_original_fields_from(last_change_for_user) if last_change_for_user.present?
        change
      end
    end

    def self.consolidated_attributes_for(user)
      computacenter_attributes_for(user)\
        .merge(meta_attributes_for(user)
        .merge(type_of_update: type_of_update(user)))
    end

    def self.change_needed?(user)
      (user.relevant_to_computacenter? && (user.destroyed? || computacenter_fields_have_changed?(user))) || \
        (last_for(user).present? && !user.relevant_to_computacenter?)
    end

    def self.computacenter_fields_have_changed?(user)
      computacenter_attributes_for(user) != last_for(user)&.computacenter_attributes
    end

    def self.computacenter_attributes_for(user)
      attrs = {
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

    def self.meta_attributes_for(user)
      {
        user_id: user.id,
        updated_at_timestamp: user.updated_at,
        type_of_update: type_of_update(user),
      }
    end

    def self.type_of_update(user)
      if last_for(user).present?
        if user.relevant_to_computacenter? && !user.destroyed?
          'Change'
        else
          'Remove'
        end
      else
        'New'
      end
    end

    def self.last_for(user)
      Computacenter::UserChange.where(user_id: user.id)
                               .order(:updated_at_timestamp)
                               .last
    end

    def is_different_to?(user_change)
      user_change.computacenter_attributes != computacenter_attributes
    end

    def computacenter_attributes
      attributes.symbolize_keys.select { |k,v| CSV_ATTRIBUTES.include?(k) }
    end

    def add_original_fields_from(change)
      assign_attributes(
        change.computacenter_attributes&.transform_keys { |k| "original_#{k.to_s}".to_sym }
      )
      self
    end

  end
end

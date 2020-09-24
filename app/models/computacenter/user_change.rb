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
    ].freeze

    enum type_of_update: { New: 0, Change: 1, Remove: 2 }

    belongs_to :user, optional: true

    def self.last_for(user)
      where(user_id: user.id)
        .order(:updated_at_timestamp)
        .last
    end

    def is_different_to?(user_change)
      user_change.computacenter_attributes != computacenter_attributes
    end

    def computacenter_attributes
      attributes.symbolize_keys.select { |k, _| CSV_ATTRIBUTES.include?(k) }
    end

    def add_original_fields_from(change)
      assign_attributes(
        change.computacenter_attributes&.transform_keys { |k| "original_#{k}".to_sym },
      )
      self
    end

    def self.for_deleted_user(user)
      if user.relevant_to_computacenter?
        # AR's previous_changes stores the last changes on an object, and
        # *doesn't* clear them after the changes have been committed -
        # so if a user is updated and then destroyed, we could get false
        # changes showing up in the deletion UserChange.
        # Fix: explicitly pass in before_user: user for a deletion
        change = for_user(user: user, before_user: user)
        change.type_of_update = 'Remove'
        change
      end
    end

    def self.for_saved_user(user)
      if user.relevant_to_computacenter? || user_before_changes(user).relevant_to_computacenter?
        if any_relevant_fields_have_changed?(user)
          for_user(user: user)
        end
      end
    end

    def self.for_user_school(user_school)
      user = user_school.user
    end

    def self.any_relevant_fields_have_changed?(user)
      user.previous_changes.any? { |attr, _changes| fields_to_monitor.include?(attr.to_sym) }
    end

    def self.for_user(user:, before_user: nil)
      before_user ||= user_before_changes(user)
      change = new(
        {
          user_id: user.id,
          updated_at_timestamp: user.updated_at,
          type_of_update: type_of_update(user: user, before_user: before_user),
        }.merge(user_fields(user))
      )
      change.assign_attributes(original_user_fields(before_user)) unless change.type_of_update == 'New'
      change
    end

    def self.user_fields(user)
      {
        first_name: user.first_name,
        last_name: user.last_name,
        email_address: user.email_address,
        telephone: user.telephone,
        responsible_body: user.effective_responsible_body&.name,
        responsible_body_urn: user.effective_responsible_body&.computacenter_identifier,
        cc_sold_to_number: user.effective_responsible_body&.computacenter_reference,
        school: user.schools.map(&:name).join('|'),
        school_urn: user.schools.map(&:urn).join('|'),
        cc_ship_to_number: user.schools.map(&:computacenter_reference).join('|'),
      }
    end

    def self.original_user_fields(before_user)
      user_fields(before_user).transform_keys{ |k| "original_#{k}" }
    end

    def self.type_of_update(user:, before_user:)
      if user.relevant_to_computacenter?
        if before_user.relevant_to_computacenter?
          'Change'
        else
          'New'
        end
      elsif before_user.relevant_to_computacenter?
        'Remove'
      end
    end

    def self.fields_to_monitor
      %i[
        full_name
        telephone
        email_address
        responsible_body_id
        privacy_notice_seen_at
        orders_devices
      ]
    end

    def self.user_before_changes(user)
      if user.id_previously_changed? # => new record
        before_user = User.new
      else
        before_user = user.dup
        before_user.assign_attributes(user.previous_changes.transform_values(&:first))
      end
      before_user
    end
  end
end

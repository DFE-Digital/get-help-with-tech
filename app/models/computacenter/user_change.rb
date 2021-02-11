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
      cc_rb_user
    ].freeze

    enum type_of_update: { New: 0, Change: 1, Remove: 2 }

    belongs_to :user, optional: true

    scope :for_user, ->(user) { where(user_id: user.id) }

    def self.latest_for_user(user)
      # when we have multiple UserChanges created in one transaction (e.g. for
      # creating a user and assigning a school), they both get the user.updated_at
      # as updated_at_timestamp. So we need a tie-breaker in that case:
      for_user(user).order(updated_at_timestamp: :asc, created_at: :asc).last
    end

    def is_different_to?(user_change)
      user_change.computacenter_attributes != computacenter_attributes
    end

    def differences_from(user_change)
      computacenter_attributes.reject { |k, v| v == user_change.computacenter_attributes[k] }
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
  end
end

require 'csv'

module Computacenter
  class BackfillLedger
    attr_accessor :users

    def initialize(users: nil)
      self.users = users || default_users
    end

    def call
      users.each do |user|
        next if UserChange.where(user_id: user.id).exists?

        UserChange.create!(
          user_id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email_address,
          telephone: user.telephone,
          responsible_body: user.effective_responsible_body&.name,
          responsible_body_urn: user.effective_responsible_body&.computacenter_identifier,
          cc_sold_to_number: user.effective_responsible_body&.computacenter_reference,
          school: user.school&.name,
          school_urn: user.school&.urn,
          cc_ship_to_number: user.school&.computacenter_reference,
          updated_at_timestamp: Time.zone.now.utc,
          type_of_update: 'New',
          original_first_name: nil,
          original_last_name: nil,
          original_email_address: nil,
          original_telephone: nil,
          original_responsible_body: nil,
          original_responsible_body_urn: nil,
          original_cc_sold_to_number: nil,
          original_school: nil,
          original_school_urn: nil,
          original_cc_ship_to_number: nil,
        )
      end
    end

  private

    def default_users
      User.who_can_order_devices.where.not(privacy_notice_seen_at: nil)
    end
  end
end

require 'csv'

module Computacenter
  class Ledger
    def initialize(users: nil)
      @users = users
    end

    def to_csv
      CSV.generate do |csv|
        csv << headers

        user_changes.each do |user_change|
          csv << [
            user_change.first_name,
            user_change.last_name,
            user_change.email_address,
            user_change.telephone,
            user_change.responsible_body,
            user_change.responsible_body_urn,
            user_change.cc_sold_to_number,
            user_change.school,
            user_change.school_urn,
            user_change.cc_ship_to_number,
            user_change.updated_at_timestamp.utc.strftime('%d/%m/%Y'),
            user_change.updated_at_timestamp.utc.strftime('%R'),
            user_change.updated_at_timestamp.utc.iso8601,
            user_change.type_of_update,
            user_change.original_email_address,
          ]
        end
      end
    end

  private

    def users
      @users ||= User.who_can_order_devices.where('privacy_notice_seen_at IS NOT NULL').limit(1)
    end

    def user_changes
      users.map do |user|
        UserChange.new(
          user_id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email_address: user.email_address,
          telephone: user.telephone,
          responsible_body: user.effective_responsible_body.name,
          responsible_body_urn: user.effective_responsible_body.computacenter_identifier,
          cc_sold_to_number: user.effective_responsible_body.computacenter_reference,
          school: user.school&.name,
          school_urn: user.school&.urn,
          cc_ship_to_number: user.school&.computacenter_reference,
          updated_at_timestamp: user.created_at,
          type_of_update: 'New',
          original_email_address: nil,
        )
      end
    end

    def headers
      [
        'First Name',
        'Last Name',
        'Email',
        'Telephone',
        'Responsible Body',
        'Responsible Body URN',
        'CC Sold To Number',
        'School',
        'School URN',
        'CC Ship To Number',
        'Date of Update', # "24/08/2020" / "dd/mm/yyyy"
        'Time of Update', # 24 hour clock
        'Timestamp of Update', # ISO
        'Type of Update', # New / Change / Remove
        'Original Email',
      ]
    end
  end
end

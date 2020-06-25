class Recipient < ApplicationRecord
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :mobile_network

  enum status: {
    requested: 'requested',
    in_progress: 'in_progress',
    queried: 'queried',
    complete: 'complete',
    cancelled: 'cancelled',
  }

  include ExportableAsCsv

  def self.exportable_attributes
    {
      id: 'ID',
      account_holder_name: 'Account holder name',
      device_phone_number: 'Device phone number',
      created_at: 'Requested',
      updated_at: 'Last updated',
      mobile_network_id: 'Mobile network ID',
      status: 'Status',
    }
  end

  def self.from_approved_users
    joins(:created_by_user).where.not(users: { approved_at: nil })
  end
end

class Recipient < ApplicationRecord
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
      full_name: 'Recipient name',
      address: 'Address',
      postcode: 'Postcode',
      is_account_holder: 'Recipient is account holder',
      account_holder_name: 'Account holder name',
      device_phone_number: 'Device phone number',
      privacy_statement_sent_to_family: 'Privacy statement sent to family',
      understands_how_pii_will_be_used: 'Understands how their PII will be used',
      created_by_user: 'Created by user ID',
      created_at: 'Requested',
      updated_at: 'Last updated',
      mobile_network_id: 'Mobile network ID',
      status: 'Status'
    }
  end
end

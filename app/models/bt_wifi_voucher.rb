class BTWifiVoucher < ApplicationRecord
  belongs_to :responsible_body, optional: true

  scope :unassigned, -> { where(responsible_body: nil) }

  include ExportableAsCsv

  def self.exportable_attributes
    {
      username: 'Username',
      password: 'Password',
    }
  end
end

class DataStage::DataUpdateRecord < ApplicationRecord
  self.table_name = 'data_update_records'

  validates :name, presence: true

  enum name: {
    schools: 'schools',
    school_links: 'school_links',
    trusts: 'trusts',
  }

  def self.last_staging_for(name)
    record = find_or_create_by!(name:)
    record.staged_at || 10.years.ago
  end

  def self.staged!(name)
    record = find_or_create_by!(name:)
    record.update!(staged_at: Time.zone.now)
  end

  def self.last_update_for(name)
    record = find_or_create_by!(name:)
    record.updated_records_at || 10.years.ago
  end

  def self.updated!(name)
    record = find_or_create_by!(name:)
    record.update!(updated_records_at: Time.zone.now)
  end
end

class Computacenter::API::CapUsageUpdatePayload < ApplicationRecord
  self.table_name = 'computacenter_cap_usage_update_payloads'

  has_many :devices_ordered_updates, dependent: :nullify

  enum status: {
    succeeded: 'succeeded',
    partially_failed: 'partially_failed',
    failed: 'failed',
  }

  def completed!(status:, succeeded_count:, failed_count:)
    update!(
      completed_at: Time.zone.now,
      status:,
      succeeded_count:,
      failed_count:,
    )
  end
end

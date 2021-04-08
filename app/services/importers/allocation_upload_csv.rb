require 'csv'

module Importers
  class AllocationUploadCsv
    attr_reader :path, :send_notification

    def initialize(path_to_csv:, send_notification: true)
      @path = path_to_csv
      @send_notification = send_notification
    end

    # urn
    # ukprn
    # allocation_delta
    # order_state # => ["can_order", "cannot_order"]

    def call
      rows.each do |row|
        job = AllocationBatchJob.create!(row.to_h.slice('urn', 'ukprn', 'allocation_delta', 'order_state').merge(batch_id: batch_id, send_notification: send_notification))
        AllocationJob.perform_later(job)
      end
    end

    def batch_id
      @batch_id ||= SecureRandom.uuid
    end

  private

    def rows
      @rows ||= CSV.read(path, headers: true)
    end
  end
end

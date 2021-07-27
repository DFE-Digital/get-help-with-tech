require 'csv'

module Importers
  class AllocationUploadCsv
    # really the `batch_id` is no longer needed but requires a large refactoring
    attr_reader :batch_id

    def initialize(path_to_csv:, send_notification: true)
      @path = path_to_csv
      @send_notification = send_notification
      @batch_id = SecureRandom.uuid
    end

    def call
      rows = CSV.read(@path, headers: true)
      # creating the rows here outside of an `ActiveJob` means this could hang the browser
      # but was necessary to avoid a larger redesign
      allocation_batch_jobs = rows.collect { |row| AllocationBatchJob.create!(row.to_h.slice('urn', 'ukprn', 'allocation_delta', 'order_state').merge(batch_id: @batch_id)) }
      AllocationJob.perform_later(allocation_batch_jobs, @send_notification)
    end
  end
end

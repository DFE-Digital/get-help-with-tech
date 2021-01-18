class ExtraMobileDataRequestStatusMigrationService
  def call
    ExtraMobileDataRequest
      .where(status: 'requested')
      .find_each do |request|
        request.update!(status: :new)
      end
  end
end

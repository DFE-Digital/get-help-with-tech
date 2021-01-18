class ExtraMobileDataRequestStatusMigrationService
  def call
    ExtraMobileDataRequest
      .queried
      .find_each do |request|
        request.update!(status: "problem_#{request.problem}")
      end
  end
end

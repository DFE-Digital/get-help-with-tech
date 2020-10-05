class StageTrustDataJob < ApplicationJob
  def perform
    StageTrustData.new.import_trusts
  end
end

class StageTrustDataJob < ApplicationJob
  def perform
    return if paused?

    StageTrustData.new.import_trusts
  end

private

  def paused?
    FeatureFlag.active?(:gias_data_stage_pause)
  end
end

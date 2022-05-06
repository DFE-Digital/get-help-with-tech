class ApplyStagedAttributeChangesToTrustsJob < ApplicationJob
  def perform
    TrustUpdateService.new.update_trusts unless paused?
  end

private

  def paused?
    FeatureFlag.active?(:gias_data_stage_pause)
  end
end

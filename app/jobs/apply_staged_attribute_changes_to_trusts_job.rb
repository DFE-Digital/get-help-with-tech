class ApplyStagedAttributeChangesToTrustsJob < ApplicationJob
  def perform
    TrustUpdateService.new.update_trusts
  end
end

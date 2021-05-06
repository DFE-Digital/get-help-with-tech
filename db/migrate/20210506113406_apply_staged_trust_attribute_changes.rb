class ApplyStagedTrustAttributeChanges < ActiveRecord::Migration[6.1]
  def up
    TrustUpdateService.new.update_trusts(last_update: 10.years.ago)
  end

  def down
    # no-op
  end
end

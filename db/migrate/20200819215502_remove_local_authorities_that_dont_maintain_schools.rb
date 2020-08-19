class RemoveLocalAuthoritiesThatDontMaintainSchools < ActiveRecord::Migration[6.0]
  def up
    LocalAuthority.where(
      organisation_type: %w[combined_authority non_metropolitan_district strategic_regional_authority],
    ).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

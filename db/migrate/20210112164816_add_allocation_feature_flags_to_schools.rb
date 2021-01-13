class AddAllocationFeatureFlagsToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :increased_sixth_form_feature_flag, :boolean, default: false
    add_column :schools, :increased_fe_feature_flag, :boolean, default: false
  end
end

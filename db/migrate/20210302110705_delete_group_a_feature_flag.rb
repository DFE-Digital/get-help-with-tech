class DeleteGroupAFeatureFlag < ActiveRecord::Migration[6.1]
  def change
    remove_column :schools, :group_a_feature_flag, :boolean, default: false, null: false
  end
end

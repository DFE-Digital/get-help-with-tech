class GroupAFeatureFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :group_a_feature_flag, :boolean, null: false, default: false
  end
end

class AddSchoolMnoFeatureFlag < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :mno_feature_flag, :boolean, default: false
  end
end

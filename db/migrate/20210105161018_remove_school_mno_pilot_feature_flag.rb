class RemoveSchoolMnoPilotFeatureFlag < ActiveRecord::Migration[6.0]
  def change
    remove_column :schools, :mno_feature_flag, :boolean, default: false
  end
end

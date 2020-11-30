class AddVcapFeatureFlagToResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :vcap_feature_flag, :boolean, default: false
  end
end

class RenameResponsibleBodyVcapColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :responsible_bodies, :vcap_feature_flag, :vcap
  end
end

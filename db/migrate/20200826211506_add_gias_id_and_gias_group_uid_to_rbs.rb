class AddGiasIdAndGiasGroupUidToRbs < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :gias_group_uid, :string, null: true, unique: true
    add_column :responsible_bodies, :gias_id, :string, null: true, unique: true
  end
end

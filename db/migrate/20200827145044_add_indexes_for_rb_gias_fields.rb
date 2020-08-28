class AddIndexesForRbGiasFields < ActiveRecord::Migration[6.0]
  def change
    add_index :responsible_bodies, :gias_group_uid, unique: true
    add_index :responsible_bodies, :gias_id, unique: true
  end
end

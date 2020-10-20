class AddStatusToResponsibleBodies < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :status, :string, null: false, default: 'open'
  end
end

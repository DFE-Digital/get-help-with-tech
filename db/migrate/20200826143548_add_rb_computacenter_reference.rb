class AddRbComputacenterReference < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :computacenter_reference, :string, null: true

    add_index :responsible_bodies, :computacenter_reference
  end
end

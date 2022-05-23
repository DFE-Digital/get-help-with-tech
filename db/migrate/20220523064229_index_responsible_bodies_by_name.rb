class IndexResponsibleBodiesByName < ActiveRecord::Migration[6.1]
  def change
    add_index :responsible_bodies, :name
  end
end

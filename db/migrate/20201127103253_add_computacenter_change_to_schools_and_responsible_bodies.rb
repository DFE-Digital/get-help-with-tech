class AddComputacenterChangeToSchoolsAndResponsibleBodies < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :computacenter_change, :string, null: false, default: 'none'
    add_index :schools, :computacenter_change

    add_column :responsible_bodies, :computacenter_change, :string, null: false, default: 'none'
    add_index :responsible_bodies, :computacenter_change
  end
end

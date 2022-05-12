class AddIndexOnComputacenterReferenceToSchools < ActiveRecord::Migration[6.1]
  def change
    add_index :schools, :computacenter_reference
  end
end

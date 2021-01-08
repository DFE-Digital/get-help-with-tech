class AddTypeToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :type, :string, null: false, default: 'CompulsorySchool'

    add_index :schools, [:type]
    add_index :schools, %i[type id]
  end
end

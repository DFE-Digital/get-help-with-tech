class AddFeTypeToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :fe_type, :text, null: true
  end
end

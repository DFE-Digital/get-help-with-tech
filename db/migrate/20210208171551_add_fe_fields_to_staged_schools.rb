class AddFeFieldsToStagedSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :staged_schools, :ukprn, :text
    add_column :staged_schools, :fe_type, :text

    add_index :staged_schools, :ukprn
  end
end

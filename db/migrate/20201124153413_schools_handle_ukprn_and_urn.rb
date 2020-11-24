class SchoolsHandleUkprnAndUrn < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :ukprn, :integer, null: true
    add_index :schools, :ukprn, unique: true

    change_column_null :schools, :urn, true
  end
end

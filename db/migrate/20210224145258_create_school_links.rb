class CreateSchoolLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :school_links do |t|
      t.references :school
      t.text :link_type, null: false
      t.integer :urn

      t.timestamps
    end
  end
end

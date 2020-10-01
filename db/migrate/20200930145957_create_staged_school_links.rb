class CreateStagedSchoolLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :staged_school_links do |t|
      t.references :staged_school
      t.integer :link_urn, null: false
      t.string :link_type, null: false
      t.timestamps
    end

    add_index :staged_school_links, %i[staged_school_id link_urn], unique: true

    remove_column :staged_schools, :link_urn
    remove_column :staged_schools, :link_type
  end
end

class CreateSchools < ActiveRecord::Migration[6.0]
  def change
    create_table :schools do |t|
      t.integer :urn, null: false
      t.string :name, null: false
      t.string :computacenter_reference
      t.references :responsible_body, foreign_key: true
      t.timestamps
    end

    add_index :schools, :urn, unique: true
    add_index :schools, :name
  end
end

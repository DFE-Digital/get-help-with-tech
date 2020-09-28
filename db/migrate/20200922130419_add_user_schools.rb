class AddUserSchools < ActiveRecord::Migration[6.0]
  def up
    create_table :user_schools do |t|
      t.references :user
      t.references :school
      t.timestamps
    end

    populate_table_sql = <<~SQL
      INSERT INTO user_schools(user_id, school_id, created_at, updated_at)
      SELECT      id, school_id, NOW(), NOW()
      FROM        users
      WHERE       school_id IS NOT NULL
    SQL
    connection.execute populate_table_sql

    add_index :user_schools, %i[user_id school_id], unique: true
    add_index :user_schools, %i[school_id user_id], unique: true

    rename_column :users, :school_id, :legacy_school_id
  end

  def down
    rename_column :users, :legacy_school_id, :school_id

    populate_column_sql = <<~SQL
      UPDATE  users
      SET     school_id = (SELECT school_id FROM user_schools WHERE user_id = users.id ORDER BY created_at LIMIT 1)
      WHERE   users.id IN (SELECT user_id FROM user_schools)
    SQL
    connection.execute populate_column_sql

    drop_table :user_schools
  end
end

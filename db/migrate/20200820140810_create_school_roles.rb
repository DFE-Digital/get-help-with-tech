class CreateSchoolRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :school_roles do |t|
      t.string :role, null: false, default: 'headteacher'
      t.string :title
      t.bigint :school_id, null: false
      t.bigint :user_id, null: false
      t.timestamps
      t.index %i[user_id school_id]
      t.index %i[school_id user_id]
    end
  end
end

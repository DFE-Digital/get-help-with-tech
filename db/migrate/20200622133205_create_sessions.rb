class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions, id: false do |t|
      t.string :id, unique: true, primary_key: true
      t.timestamps
    end
  end
end

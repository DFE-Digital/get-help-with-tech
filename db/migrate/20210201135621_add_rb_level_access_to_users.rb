class AddRbLevelAccessToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :rb_level_access, :boolean, null: false, default: false
  end
end

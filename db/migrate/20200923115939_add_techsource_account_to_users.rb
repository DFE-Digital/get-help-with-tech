class AddTechsourceAccountToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :has_techsource_account, :boolean, default: false
  end
end

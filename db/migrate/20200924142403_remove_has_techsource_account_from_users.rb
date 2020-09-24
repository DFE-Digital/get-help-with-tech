class RemoveHasTechsourceAccountFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :has_techsource_account, :boolean
  end
end

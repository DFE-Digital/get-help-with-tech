class AddTechsourceAccountConfirmedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :techsource_account_confirmed_at, :datetime, null: true, default: nil
  end
end

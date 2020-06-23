class MakeUserEmailAddressUnique < ActiveRecord::Migration[6.0]
  def change
    remove_index :users, :email_address

    users_with_duplicates = User.group(:email_address).having("count(*)  > 1")
    while(!users_with_duplicates.count.empty?) do
      users_with_duplicates.select("email_address, count(*)").each do |u|
        User.where(email_address: u.email_address).first.destroy
      end
      users_with_duplicates = User.group(:email_address).having("count(*)  > 1")
    end
    add_index :users, [:email_address], unique: :true
  end
end

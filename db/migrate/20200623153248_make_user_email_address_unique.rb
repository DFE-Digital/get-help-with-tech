class MakeUserEmailAddressUnique < ActiveRecord::Migration[6.0]
  def duplicate_email_query
    User.group(:email_address).having('count(*)  > 1')
  end

  def change
    remove_index :users, :email_address

    users_with_duplicates = duplicate_email_query
    # NOTE: it's a grouped query, so 'count' isn't actually an integer count,
    # but a hash of email_address=>number of records with that email_address
    # Hence 'empty?' rather than '== 0'
    until users_with_duplicates.count.empty?
      users_with_duplicates.select('email_address, count(*)').each do |u|
        User.where(email_address: u.email_address).first.destroy
      end
      users_with_duplicates = duplicate_email_query
    end
    add_index :users, [:email_address], unique: true
  end
end

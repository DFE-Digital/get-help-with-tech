class AddUniqueIndexOnLowercaseEmail < ActiveRecord::Migration[6.0]
  def change
    add_index :users,
              'lower(email_address)',
              name: 'index_users_on_lower_email_address_unique',
              unique: true
  end
end

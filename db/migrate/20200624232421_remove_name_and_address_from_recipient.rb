class RemoveNameAndAddressFromRecipient < ActiveRecord::Migration[6.0]
  def change
    remove_column :recipients, :full_name
    remove_column :recipients, :address
    remove_column :recipients, :postcode
  end
end

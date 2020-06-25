class RemoveNameAndAddressFromRecipient < ActiveRecord::Migration[6.0]
  def change
    remove_column :recipients, :full_name, :string
    remove_column :recipients, :address, :string
    remove_column :recipients, :postcode, :string
  end
end

class AddNormalisedNameToExtraMobileDataRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :extra_mobile_data_requests, :normalised_name, :string, null: true
    add_index :extra_mobile_data_requests, :normalised_name
  end
end

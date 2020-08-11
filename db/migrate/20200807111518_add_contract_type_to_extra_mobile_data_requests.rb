class AddContractTypeToExtraMobileDataRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :extra_mobile_data_requests, :contract_type, :string
  end
end

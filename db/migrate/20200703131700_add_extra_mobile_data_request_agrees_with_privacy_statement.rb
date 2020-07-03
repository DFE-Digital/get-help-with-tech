class AddExtraMobileDataRequestAgreesWithPrivacyStatement < ActiveRecord::Migration[6.0]
  def change
    add_column :extra_mobile_data_requests, :agrees_with_privacy_statement, :boolean, null: true
  end
end

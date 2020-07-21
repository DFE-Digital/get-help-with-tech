class RemoveExtraMobileDataRequestsCreatedByUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :extra_mobile_data_requests, :created_by_user, :bigint
  end
end

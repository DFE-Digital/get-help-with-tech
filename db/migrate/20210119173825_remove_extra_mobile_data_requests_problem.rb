class RemoveExtraMobileDataRequestsProblem < ActiveRecord::Migration[6.0]
  def change
    remove_column :extra_mobile_data_requests, :problem, :string
  end
end

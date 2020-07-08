class AddExtraMobileDataRequestProblem < ActiveRecord::Migration[6.0]
  def change
    add_column :extra_mobile_data_requests, :problem, :string, null: true
  end
end

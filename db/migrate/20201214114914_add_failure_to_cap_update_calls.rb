class AddFailureToCapUpdateCalls < ActiveRecord::Migration[6.0]
  def change
    add_column :cap_update_calls, :failure, :boolean, default: false
  end
end

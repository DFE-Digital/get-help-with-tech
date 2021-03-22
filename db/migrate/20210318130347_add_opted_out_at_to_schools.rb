class AddOptedOutAtToSchools < ActiveRecord::Migration[6.1]
  def change
    add_column :schools, :opted_out_of_comms_at, :datetime, null: true
  end
end

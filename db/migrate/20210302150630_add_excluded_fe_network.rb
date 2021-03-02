class AddExcludedFeNetwork < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_networks, :excluded_fe_network, :boolean, default: false, null: false
  end
end

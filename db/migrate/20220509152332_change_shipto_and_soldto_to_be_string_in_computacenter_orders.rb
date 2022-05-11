class ChangeShiptoAndSoldtoToBeStringInComputacenterOrders < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :computacenter_orders, :sold_to, :string
        change_column :computacenter_orders, :ship_to, :string
      end

      dir.down do
        change_column :computacenter_orders, :sold_to, :integer
        change_column :computacenter_orders, :ship_to, :integer
      end
    end
  end
end

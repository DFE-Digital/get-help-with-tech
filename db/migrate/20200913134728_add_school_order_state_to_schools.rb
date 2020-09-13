class AddSchoolOrderStateToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :order_state, :string, null: false, default: :cannot_order
  end
end

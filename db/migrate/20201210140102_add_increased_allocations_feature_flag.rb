class AddIncreasedAllocationsFeatureFlag < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :increased_allocations_feature_flag, :boolean, default: false
  end
end

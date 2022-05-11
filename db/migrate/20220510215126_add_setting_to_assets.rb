class AddSettingToAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :assets, :setting_id, :bigint
    add_column :assets, :setting_type, :string

    add_index :assets, %i[setting_type setting_id]
  end
end

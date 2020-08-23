class DisallowNullPreorderInformationStatus < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up   { change_column :preorder_information, :status, :string, null: false }
      dir.down { change_column :preorder_information, :status, :string, null: true }
    end
  end
end

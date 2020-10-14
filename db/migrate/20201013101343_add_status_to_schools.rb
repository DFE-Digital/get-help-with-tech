class AddStatusToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :status, :string, null: false, default: 'open'
  end
end

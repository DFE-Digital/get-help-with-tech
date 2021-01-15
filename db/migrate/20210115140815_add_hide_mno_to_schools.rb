class AddHideMnoToSchools < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :hide_mno, :boolean, default: false
  end
end

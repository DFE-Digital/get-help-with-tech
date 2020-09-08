class AddPreorderInformationSchoolContactedAt < ActiveRecord::Migration[6.0]
  def change
    add_column :preorder_information, :school_contacted_at, :datetime
  end
end

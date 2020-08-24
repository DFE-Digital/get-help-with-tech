class AddChromebookFieldsToPreorderInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :preorder_information, :will_need_chromebooks, :boolean, null: true
    add_column :preorder_information, :school_or_rb_domain, :string, null: true
    add_column :preorder_information, :recovery_email_address, :string, null: true
  end
end

class AddContactReferenceToPreorderInformation < ActiveRecord::Migration[6.0]
  def change
    add_reference :preorder_information, :school_contact, foreign_key: true
  end
end

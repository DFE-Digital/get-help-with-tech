class AddKeyContactToResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_reference :responsible_bodies, :key_contact, foreign_key: { to_table: :users }
  end
end

class UserOptionallyBelongsToResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :responsible_body
  end
end

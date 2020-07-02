class AddResponsibleBodyIdToAllocationRequest < ActiveRecord::Migration[6.0]
  def change
    add_reference :allocation_requests, :responsible_body, null: false
  end
end

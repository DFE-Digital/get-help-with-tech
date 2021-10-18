class CapUpdateCall < ApplicationRecord
  #### PENDING MIGRATIONS
  ####   Add t.string "device_type", null: false
  ####   Add :school_id
  ####   Remove :school_device_allocation_id

  belongs_to :school
end

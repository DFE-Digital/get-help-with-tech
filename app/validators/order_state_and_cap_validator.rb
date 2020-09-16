class OrderStateAndCapValidator < ActiveModel::Validator
  def validate(record)
    validate_cap_lte_allocation(record)
    validate_cap_gte_devices_ordered(record)
  end

private

  def validate_cap_lte_allocation(record)
    if record.cap.to_i > record.allocation.to_i
      record.errors.add(:cap, :lte_allocation, allocation: record.allocation.to_i)
    end
  end

  def validate_cap_gte_devices_ordered(record)
    if record.cap.to_i < record.devices_ordered.to_i
      record.errors.add(:cap, :gte_devices_ordered, devices_ordered: record.devices_ordered.to_i)
    end
  end
end

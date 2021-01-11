class CapAndAllocationValidator < ActiveModel::Validator
  def validate(record)
    validate_cap_lte_allocation(record)
  end

private

  def validate_cap_lte_allocation(record)
    if record.raw_cap.to_i > record.raw_allocation.to_i
      record.errors.add(:cap, :lte_allocation, allocation: record.raw_allocation.to_i)
    end
  end
end

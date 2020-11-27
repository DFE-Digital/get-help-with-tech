class CompulsorySchool < School
  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }

  def delivery_address
    delivery_addresses.first
  end

  def to_param
    urn.to_s
  end
end

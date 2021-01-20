class CompulsorySchool < School
  validates :urn, presence: true, format: { with: /\A\d{6}\z/ }

  def to_param
    urn.to_s
  end

  def institution_type
    'school'
  end
end

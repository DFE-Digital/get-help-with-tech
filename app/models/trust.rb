class Trust < ResponsibleBody
  enum organisation_type: {
    multi_academy_trust: 'Multi-academy trust',
    single_academy_trust: 'Single-academy trust',
  }

  validates :organisation_type, presence: true
end

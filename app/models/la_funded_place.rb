class LaFundedPlace < School
  validates :provision_urn, presence: true

  enum provision_type: {
    iss: 'iss',
    scl: 'scl',
  }, _suffix: 'provision'

  def urn
    provision_urn
  end

  def to_param
    provision_urn
  end

  def institution_type
    'organisation'
  end
end

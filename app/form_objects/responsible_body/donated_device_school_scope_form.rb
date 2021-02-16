class ResponsibleBody::DonatedDeviceSchoolScopeForm
  include ActiveModel::Model

  attr_accessor :scope

  validates :scope,
            presence: { message: 'Choose whether which schools you would like to opt-in to the scheme' },
            inclusion: { in: %w[all some], message: 'Choose all or some' }

  def self.options
    [
      OpenStruct.new(value: 'all', label: 'Opt in all schools'),
      OpenStruct.new(value: 'some', label: 'Opt in some schools'),
    ]
  end

  def all_schools?
    scope == 'all'
  end
end

class ResponsibleBody::DonatedDevicePolicy < ResponsibleBody::BasePolicy
  alias_method :interest_confirmation?, :create?
  alias_method :all_or_some_schools?, :create?
  alias_method :select_schools?, :create?
  alias_method :device_types?, :create?
  alias_method :how_many_devices?, :create?
  alias_method :check_answers?, :create?
end

class School::DonatedDevicePolicy < School::BasePolicy
  alias_method :interest_confirmation?, :create?
  alias_method :device_types?, :create?
  alias_method :how_many_devices?, :create?
  alias_method :check_answers?, :create?
end

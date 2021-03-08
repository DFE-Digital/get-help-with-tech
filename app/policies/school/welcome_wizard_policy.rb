class School::WelcomeWizardPolicy < School::BasePolicy
  alias_method :next_step?, :create?
end

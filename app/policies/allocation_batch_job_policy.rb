class AllocationBatchJobPolicy < SupportPolicy
  class Scope < Scope
    def resolve
      if user.is_support?
        scope.all
      else
        raise 'Unexpected user type in AllocationBatchJobPolicy scope'
      end
    end
  end

  def send_notifications?
    user.is_support?
  end
end

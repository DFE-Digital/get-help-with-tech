class BulkAllocationService
  attr_reader :success, :failures, :urn_count
  def initialize
    @success = []
    @failures = []
    @urn_count = 0
  end

  def unlock!(urn_list)
    @urn_count = urn_list.count

    urn_list.each do |urn|
      begin
        school = School.find_by(urn: urn)
        if school
          update_cap_to_full_allocation!(school)
          add_success(school)
        else
          add_failure(urn, 'URN not found')
        end
      rescue => e
        add_failure(urn, e.message)
      end
    end
    self
  end

  def success_count
    @success.count
  end

  def failure_count
    @failures.count
  end

private

  def update_cap_to_full_allocation!(school)
    cus = CapUpdateService.new(school: school, device_type: 'std_device')
    cus.update!(order_state: 'can_order', cap: nil)
  end

  def add_success(school)
    @success << { urn: school.urn, message: school.name }
  end

  def add_failure(urn, message)
    @failures << { urn: urn, message: message }
  end
end

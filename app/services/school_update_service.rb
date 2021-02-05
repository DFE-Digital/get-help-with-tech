class SchoolUpdateService
  def update_schools
    # look at the schools that have changed since the last update
    last_update = DataStage::DataUpdateRecord.last_update_for(:schools)

    # attribute updates for schools
    DataStage::School.updated_since(last_update).find_each(batch_size: 100) do |staged_school|
      update_school(staged_school) if staged_school.counterpart_school.present?
    end

    DataStage::DataUpdateRecord.updated!(:schools)
  end

  def create_school!(staged_school)
    Rails.logger.info("Adding school #{staged_school.urn} #{staged_school.name} (#{staged_school.status})")
    responsible_body_exists!(staged_school.responsible_body_name)

    school = School.create!(staged_school.staged_attributes)

    predecessor = find_predecessor(staged_school)

    setup_preorder_information(school, predecessor)

    setup_allocations(school, predecessor)

    move_users(school, predecessor)

    close_predecessor!(predecessor)

    school
  end

  def schools_that_need_to_be_added
    DataStage::School.gias_status_open.where.not(urn: School.gias_status_open.select(:urn))
  end

  def schools_that_need_to_be_closed
    DataStage::School.gias_status_closed.where(urn: School.gias_status_open.select(:urn))
  end

private

  def find_predecessor(staged_school)
    last_link = staged_school.school_links.any_predecessor.order(created_at: :asc).last
    School.find_by(urn: last_link.link_urn) if last_link
  end

  def setup_preorder_information(school, predecessor)
    who_will_order = predecessor&.preorder_information&.who_will_order_devices || school.responsible_body.who_will_order_devices&.singularize
    school.create_preorder_information!(who_will_order_devices: who_will_order) unless who_will_order.nil?
  end

  def setup_allocations(school, predecessor)
    school.device_allocations.std_device.create!(allocation: 0)
    school.device_allocations.coms_device.create!(allocation: 0)

    if predecessor
      predecessor.device_allocations.each do |allocation|
        alloc = allocation.raw_allocation
        ordered = allocation.raw_devices_ordered
        cap = allocation.raw_cap
        spare_allocation = alloc - ordered

        if spare_allocation > 0
          SchoolDeviceAllocation.transaction do
            school.device_allocations
              .send(allocation.device_type).first
              .update!(allocation: spare_allocation,
                       cap: spare_allocation)

            allocation.update!(allocation: ordered, cap: ordered)
          end
        end
      end
    end
  end

  def move_users(school, predecessor)
    if predecessor
      predecessor.users.each { |u| school.users << u }
      predecessor.user_schools.destroy_all
    end
  end

  def close_predecessor!(predecessor)
    if predecessor && predecessor.gias_status_open?
      predecessor.update!(status: 'closed', computacenter_change: 'closed')
    end
  end

  def responsible_body_exists!(responsible_body_name)
    raise DataStage::Error.new("Cannot find responsible body '#{responsible_body_name}'") unless ResponsibleBody.find_by(name: responsible_body_name)
  end

  def update_school(staged_school)
    staged_school.counterpart_school.update!(staged_school.staged_attributes.merge(computacenter_change: 'amended'))
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.record.errors)
  end
end

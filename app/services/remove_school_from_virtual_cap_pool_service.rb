class RemoveSchoolFromVirtualCapPoolService
#   attr_reader :notify, :school, :rb
#
#   delegate :laptop_allocation_id, :router_allocation_id, to: :school
#
#   def initialize(school, notify: true)
#     @notify = notify
#     @school = school
#     @rb = school.responsible_body
#   end
#
#   def call
#     remove_school! if school.in_virtual_cap_pool?
#   rescue StandardError => e
#     failed(e)
#   end
#
# private
#
#   def notify_other_agents
#     CapUpdateNotificationsService.new(*school.cap_updates, notify_computacenter: false, notify_school: false).call
#   end
#
#   def remove_school!
#     school.transaction do
#       # school.update!(vcap: false)
#       rb.calculate_virtual_caps!
#       notify_other_agents if notify
#       school.refresh_preorder_status! if notify
#       true
#     end
#   end
#
#   def failed(e)
#     log_error(e)
#     false
#   end
#
#   def log_error(e)
#     school.errors.add(:base, e.message)
#     Rails.logger.error(e.message)
#     Sentry.capture_exception(e)
#   end
end

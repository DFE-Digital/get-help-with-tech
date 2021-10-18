class AddSchoolToVirtualCapPoolService
#   attr_reader :school, :rb
#
#   def initialize(school)
#     @school = school
#     @rb = school.responsible_body
#   end
#
#   def call
#     add_school! if addable?
#   rescue StandardError => e
#     failed(e)
#   end
#
# private
#
#   def addable?
#     rb.has_virtual_cap_feature_flags? && !school.la_funded_provision? && school.orders_managed_centrally?
#   end
#
#   def add_school!
#     # school.update!(vcap: true)
#     rb.calculate_virtual_caps!
#     # notify_other_agents
#     school.refresh_preorder_status!
#     true
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
#
#   def notify_other_agents
#     %i[laptop router].each do |device_type|
#       next if school.raw_cap(device_type) != school.raw_devices_ordered(device_type)
#
#       CapUpdateNotificationsService.new(school.cap_update(device_type),
#                                         notify_computacenter: false,
#                                         notify_school: false).call
#     end
#   end
end

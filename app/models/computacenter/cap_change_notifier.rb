# module Computacenter
#   module CapChangeNotifier
#     def notify_computacenter_of_cap_changes?
#       Settings.computacenter.outgoing_api&.endpoint.present?
#     end
#
#     def update_cap_on_computacenter!(allocation_ids)
#       ids = Array(allocation_ids)
#       api_request = Computacenter::OutgoingAPI::CapUpdateRequest.new(allocation_ids: ids)
#       response = api_request.post!
#
#       SchoolDeviceAllocation.where(id: ids).find_each do |allocation|
#         allocation.update!(
#           cap_update_request_timestamp: api_request.timestamp,
#           cap_update_request_payload_id: api_request.payload_id,
#         )
#         allocation.cap_update_calls << CapUpdateCall.new(request_body: api_request.body, response_body: response.body)
#       end
#       response
#     rescue Computacenter::OutgoingAPI::Error => e
#       ids.each do |allocation_id|
#         CapUpdateCall.create!(
#           school_device_allocation_id: allocation_id,
#           request_body: e.cap_update_request.body,
#           response_body: e.cap_update_request&.response&.body,
#           failure: true,
#         )
#       end
#
#       raise
#     end
#   end
# end

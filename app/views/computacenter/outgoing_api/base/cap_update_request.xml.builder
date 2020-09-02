xml.instruct!
xml.CapAdjustmentRequest(payloadID: assigns[:payload_id], dateTime: Time.zone.now.iso8601) do
  assigns[:allocations].each do |allocation|
    xml.Record(capType: allocation.computacenter_cap_type,
               shipTo: allocation.school.computacenter_reference,
               capAmount: allocation.cap)
  end
end

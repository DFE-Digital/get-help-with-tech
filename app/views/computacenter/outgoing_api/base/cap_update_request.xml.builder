xml.instruct!
xml.CapAdjustmentRequest(payloadID: assigns[:payload_id], dateTime: assigns[:timestamp].iso8601) do
  assigns[:allocations].each do |allocation|
    xml.Record(capType: allocation.cap_type,
               shipTo: allocation.ship_to,
               capAmount: allocation.cap)
  end
end

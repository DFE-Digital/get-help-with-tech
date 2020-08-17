xml.instruct!
xml.CapAdjustmentRequest( payloadID: assigns[:payload_id], dateTime: "2020-06-18T09:20:45Z" ) do
  assigns[:allocations].each do |allocation|
    xml.Record( capType: allocation.computacenter_cap_type,
                shipTo: allocation.school.computacenter_reference,
                capAmount: allocation.allocation )
  end
end

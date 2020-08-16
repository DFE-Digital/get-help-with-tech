xml.instruct!
xml.CapUsageResponse('payloadId' => @batch.payload_id, 'dateTime' => Time.zone.now.iso8601) do
  xml.HeaderResult('status' => @batch.status) do
    xml.FailedRecords do
      @batch.failed_updates.each do |update|
        xml.Record(
          'capType' => update.cap_type,
          'shipTo' => update.ship_to,
          'capAmount' => update.cap_amount,
          'usedCap' => update.cap_used,
          'status' => update.status,
          'errorDetails' => update.error,
        )
      end
    end
  end
end

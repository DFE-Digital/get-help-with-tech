xml.instruct!
xml.CapUsageResponse( 'payloadId' => @batch.payload_id, 'dateTime' => Time.zone.now.iso8601 ) do
  xml.HeaderResult( 'status' => @batch.status ) do
    xml.FailedRecords do
      for update in @batch.updates.select(&:failed?) do
        xml.Record(
          'capType' => update.cap_type,
          'shipTo' => update.ship_to,
          'capAmount' => update.cap_amount,
          'usedCap' => update.cap_used,
          'status' => update.status,
          'errorDetails' => update.error
        )
      end
    end
  end
end

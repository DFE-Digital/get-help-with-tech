class ExtraMobileDataRequestStatusFile < CsvDataFile
  attr_accessor :path

  def requests(&block)
    records(&block)
  end

protected

  def extract_record(row)
    {
      id: row['ID'],
      account_holder_name: row['Account holder name'],
      device_phone_number: row['Device phone number'],
      mobile_network_id: row['Mobile network ID'],
      status: row['Status'],
    }
  end
end

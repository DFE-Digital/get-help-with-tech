class PopulateHashedColumnsOnExtraMobileDataRequest < ActiveRecord::Migration[6.1]
  def change
    sql = <<-SQL
      UPDATE  extra_mobile_data_requests
      SET     hashed_account_holder_name = MD5(account_holder_name),
              hashed_normalised_name = MD5(normalised_name),
              hashed_device_phone_number = MD5(device_phone_number)
    SQL

    ExtraMobileDataRequest.connection.execute(sql)
  end
end

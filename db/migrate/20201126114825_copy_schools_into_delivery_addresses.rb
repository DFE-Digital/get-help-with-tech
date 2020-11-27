class CopySchoolsIntoDeliveryAddresses < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.connection.execute("
      INSERT INTO delivery_addresses(
        school_id,
        computacenter_reference,
        address_1,
        address_2,
        address_3,
        town,
        county,
        postcode,
        created_at,
        updated_at
      )
      SELECT
      id,
      computacenter_reference,
      address_1,
      address_2,
      address_3,
      town,
      county,
      postcode,
      created_at,
      updated_at
      FROM schools")
  end

  def down
    ActiveRecord::Base.connection.execute('TRUNCATE delivery_addresses')
  end
end

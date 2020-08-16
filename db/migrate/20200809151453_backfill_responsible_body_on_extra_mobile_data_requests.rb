class BackfillResponsibleBodyOnExtraMobileDataRequests < ActiveRecord::Migration[6.0]
  def up
    execute '
      UPDATE
          extra_mobile_data_requests r
      SET
          responsible_body_id = u.responsible_body_id
      FROM
          users u
      WHERE
          r.created_by_user_id = u.id
          AND r.responsible_body_id IS NULL
      '
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

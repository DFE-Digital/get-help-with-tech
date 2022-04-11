class ChangeResponsibleBodyInConnectivityPilotDefaultToFalse < ActiveRecord::Migration[6.0]
  def up
    change_column :responsible_bodies, :in_connectivity_pilot, :boolean, null: true, default: false

    # Only set this flag to true if there is at least one user for the RB
    connection.execute <<~SQL
      UPDATE  responsible_bodies
      SET     in_connectivity_pilot = EXISTS(
        SELECT id
        FROM users
        WHERE responsible_body_id = responsible_bodies.id
      )
    SQL
  end

  def down
    change_column :responsible_bodies, :in_connectivity_pilot, :boolean, null: true, default: true
  end
end

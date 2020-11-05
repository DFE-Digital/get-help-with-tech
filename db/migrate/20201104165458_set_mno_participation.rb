class SetMnoParticipation < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      UPDATE mobile_networks SET participation_in_pilot='no';
      UPDATE mobile_networks SET participation_in_pilot='yes' WHERE brand IN ('Three','SMARTY','Virgin Mobile');
    SQL
  end
end

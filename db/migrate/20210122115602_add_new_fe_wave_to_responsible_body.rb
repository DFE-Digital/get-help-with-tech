class AddNewFeWaveToResponsibleBody < ActiveRecord::Migration[6.0]
  def change
    add_column :responsible_bodies, :new_fe_wave, :boolean, default: false
  end
end

class AddReportableEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :reportable_events do |t|
      t.string      :event_name
      t.string      :record_type, null: true
      t.bigint      :record_id, null: true
      t.datetime    :event_time
      t.timestamps
    end

    add_index :reportable_events, %i[event_name event_time record_type record_id], name: 'ix_re_name_time_type_id'
    add_index :reportable_events, %i[record_type record_id event_name event_time], name: 'ix_re_type_id_name_time'
  end
end

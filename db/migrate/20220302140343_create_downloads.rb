class CreateDownloads < ActiveRecord::Migration[6.1]
  def change
    create_table :downloads do |t|
      t.string :uuid
      t.integer :user_id
      t.string :tag
      t.string :filetype
      t.string :filename
      t.string :encrypted_content
      t.datetime :last_downloaded_at

      t.timestamps
    end
  end
end

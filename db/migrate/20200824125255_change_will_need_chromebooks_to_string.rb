class ChangeWillNeedChromebooksToString < ActiveRecord::Migration[6.0]
  def change
    reversible do |migrate|
      migrate.up do
        change_column :preorder_information, :will_need_chromebooks, :string, null: true
        connection.execute <<~SQL
          UPDATE  preorder_information
          SET     will_need_chromebooks = 'yes'
          WHERE   will_need_chromebooks = 'true'
        SQL

        connection.execute <<~SQL
          UPDATE  preorder_information
          SET     will_need_chromebooks = 'no'
          WHERE   will_need_chromebooks = 'false'
        SQL
      end

      migrate.down do
        add_column :preorder_information, :tmp_will_need_chromebooks, :boolean, null: true
        connection.execute <<~SQL
          UPDATE  preorder_information
          SET     tmp_will_need_chromebooks = true
          WHERE   will_need_chromebooks = 'yes'
        SQL

        connection.execute <<~SQL
          UPDATE  preorder_information
          SET     tmp_will_need_chromebooks = false
          WHERE   will_need_chromebooks = 'no'
        SQL
        remove_column :preorder_information, :will_need_chromebooks
        add_column :preorder_information, :will_need_chromebooks, :boolean, null: true
        connection.execute <<~SQL
          UPDATE  preorder_information
          SET     will_need_chromebooks = tmp_will_need_chromebooks
          WHERE   tmp_will_need_chromebooks IS NOT NULL
        SQL
        remove_column :preorder_information, :tmp_will_need_chromebooks
      end
    end
  end
end

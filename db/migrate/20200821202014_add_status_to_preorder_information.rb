class AddStatusToPreorderInformation < ActiveRecord::Migration[6.0]
  def change
    add_column :preorder_information, :status, :string

    PreorderInformation.all.each do |info|
      info.update!(status: info.infer_status)
    end

    add_index :preorder_information, :status
  end
end

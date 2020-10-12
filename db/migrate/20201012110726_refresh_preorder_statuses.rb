class RefreshPreorderStatuses < ActiveRecord::Migration[6.0]
  def change
    PreorderInformation.all.each(&:refresh_status!)
  end
end

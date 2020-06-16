class PopulateAccountHolderNameForAllRecipients < ActiveRecord::Migration[6.0]
  def change
    Recipient.where(is_account_holder: true).update_all('account_holder_name=full_name')
  end
end

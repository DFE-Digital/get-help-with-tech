class Computacenter::UserLedgerController < Computacenter::BaseController
  def index
    @user_ids = policy_scope(User).pluck(:id)
    @ledger = DeviceSupplier::ExportUsersService.call(@user_ids)

    respond_to do |format|
      format.csv do
        send_data @ledger, filename: "#{Time.zone.now.iso8601}_device_supplier_allocations_export.csv"
      end
    end
  end

  def changes
    @user_changes = Computacenter::UserChange.all.order(:updated_at_timestamp)
    @ledger = Computacenter::Ledger.new(user_changes: @user_changes)

    respond_to do |format|
      format.csv do
        render csv: @ledger.to_csv, filename: "computacenter-users-#{Time.zone.now.iso8601}"
      end
    end
  end
end

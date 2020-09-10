class Computacenter::UserLedgerController < Computacenter::BaseController
  def index
    @user_changes = Computacenter::UserChange.all.order(:updated_at_timestamp)
    @ledger = Computacenter::Ledger.new(user_changes: @user_changes)

    respond_to do |format|
      format.csv do
        render csv: @ledger.to_csv, filename: "computacenter-users-#{Time.zone.now.iso8601}"
      end
    end
  end
end

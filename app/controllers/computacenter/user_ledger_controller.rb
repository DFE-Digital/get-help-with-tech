class Computacenter::UserLedgerController < Computacenter::BaseController
  def index
    @users = User.who_can_order_devices
                .who_have_seen_privacy_notice
    @ledger = Computacenter::Ledger.new(users: @users)

    respond_to do |format|
      format.csv do
        render csv: @ledger.to_csv, filename: "computacenter-users-#{Time.zone.now.iso8601}"
      end
    end
  end
end

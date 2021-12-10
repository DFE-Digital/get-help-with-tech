class Computacenter::AllocationLedgerController < Computacenter::BaseController
  def index
    @school_ids = policy_scope(School).pluck(:id)
    @ledger = DeviceSupplier::ExportAllocationsService.call(@school_ids)

    respond_to do |format|
      format.csv do
        send_data @ledger, filename: "#{Time.zone.now.iso8601}_device_supplier_allocations_export.csv"
      end
    end
  end
end

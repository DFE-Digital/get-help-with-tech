class Computacenter::AllocationLedgerController < Computacenter::BaseController
  def index
    @ledger = DeviceSupplier::ExportAllocationsService.new

    respond_to do |format|
      format.csv do
        send_data @ledger.to_csv, filename: "#{Time.zone.now.iso8601}_device_supplier_allocations_export.csv"
      end
    end
  end
end

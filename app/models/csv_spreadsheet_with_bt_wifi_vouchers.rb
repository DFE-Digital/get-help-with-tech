require 'csv'

class CSVSpreadsheetWithBTWifiVouchers
  def initialize(vouchers)
    @vouchers = vouchers
  end

  def to_csv
    CSV.generate do |csv|
      csv << %w[Username Password]
      @vouchers.each do |voucher|
        csv << [voucher.username, voucher.password]
      end
    end
  end
end

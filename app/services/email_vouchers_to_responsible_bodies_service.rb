require 'notifications/client'

class EmailVouchersToResponsibleBodiesService
  TEMPLATE_ID = '36216420-24b0-418b-a6e6-79bd4c728e8a'.freeze

  def initialize
    @client = Notifications::Client.new(ENV.fetch('GOVUK_NOTIFY_API_KEY', nil))
  end

  def call
    BTWifiVoucher.grouped_by_recipient_responsible_body.each do |responsible_body, vouchers|
      email_vouchers_to_responsible_body(responsible_body, vouchers)
    end
  end

private

  def email_vouchers_to_responsible_body(responsible_body, vouchers)
    link_to_file = upload_to_notify(CSVSpreadsheetWithBTWifiVouchers.new(vouchers).to_csv)
    number_of_allocations = vouchers.size

    responsible_body.users.approved.each do |user|
      email_vouchers_to_user(
        user.email_address,
        link_to_file: link_to_file,
        number_of_allocations: number_of_allocations,
      )
    end
  end

  def email_vouchers_to_user(email_address, link_to_file:, number_of_allocations:)
    @client.send_email(
      email_address: email_address,
      template_id: TEMPLATE_ID,
      personalisation: {
        number_of_allocations: number_of_allocations,
        link_to_voucher_spreadsheet: link_to_file,
      },
    )
  end

  def upload_to_notify(csv)
    Notifications.prepare_upload(StringIO.new(csv))
  end
end

class ExtraMobileDataRequestRow
  def initialize(row_hash)
    @row_hash = row_hash
  end

  def build_request
    ExtraMobileDataRequest.new(fetch_request_attrs) if fetch_request_attrs
  end

private

  def fetch_request_attrs
    attrs = {
      account_holder_name:,
      device_phone_number: mobile_phone_number,
      mobile_network_id:,
      contract_type:,
      agrees_with_privacy_statement:,
    }
    attrs unless attrs.values.all?(&:nil?)
  end

  def account_holder_name
    @row_hash[:account_holder_name]
  end

  def mobile_phone_number
    @row_hash[:mobile_phone_number]
  end

  def mobile_network_id
    network_name = @row_hash[:mobile_network]
    MobileNetwork.find_by(brand: network_name)&.id
  end

  def contract_type
    value = @row_hash[:pay_monthly_or_payg]
      &.parameterize
      &.gsub('-', '_')
    value if ExtraMobileDataRequest.contract_types[value]
  end

  def agrees_with_privacy_statement
    @row_hash[:has_someone_shared_the_privacy_statement_with_the_account_holder]
  end
end

require 'rails_helper'

RSpec.describe ExtraMobileDataRequestStatusMigrationService do
  subject(:service) { described_class.new }

  it 'maps any queried MNO requests to corresponding problem statuses' do
    incorrect_number = create(:extra_mobile_data_request, status: :queried, problem: :incorrect_phone_number)
    no_match_for_account_name = create(:extra_mobile_data_request, status: :queried, problem: :no_match_for_account_name)

    service.call

    expect(incorrect_number.reload.problem_incorrect_phone_number?).to be_truthy
    expect(no_match_for_account_name.reload.problem_no_match_for_account_name?).to be_truthy
  end

  it 'does not change the status of any non-queried MNO requests' do
    request = create(:extra_mobile_data_request, status: :requested)

    service.call

    expect(request.reload.requested?).to be_truthy
  end
end

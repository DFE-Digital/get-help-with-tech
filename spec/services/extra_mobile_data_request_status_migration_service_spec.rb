require 'rails_helper'

RSpec.describe ExtraMobileDataRequestStatusMigrationService do
  subject(:service) { described_class.new }

  it 'maps any requested MNO requests to the new status' do
    requested = create(:extra_mobile_data_request, status: :requested)

    service.call

    expect(requested.reload.new_status?).to be_truthy
  end

  it 'does not change the status of any MNO requests in non-requested status' do
    request = create(:extra_mobile_data_request, status: :in_progress)

    service.call

    expect(request.reload.in_progress_status?).to be_truthy
  end
end

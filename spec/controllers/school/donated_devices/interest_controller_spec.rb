require 'rails_helper'

RSpec.describe School::DonatedDevices::InterestController do
  let(:support_user) { create(:support_user) }
  let(:school_user) { create(:school_user) }
  let(:school) { school_user.school }

  actions = %w[
    create
    interest_confirmation
    device_types
    how_many_devices
    check_answers
  ]

  actions.each do |action|
    describe "##{action}" do
      context 'when support user impersonating' do
        before do
          create(:donated_device_request, device_types: [:windows], schools: [school.id])
          sign_in_as support_user
          impersonate school_user
        end

        it 'returns forbidden' do
          post action, params: {
            urn: school.urn,
            donated_device_interest_form: { device_interest: 'asd' },
          }

          expect(response).to be_forbidden
        end
      end
    end
  end
end

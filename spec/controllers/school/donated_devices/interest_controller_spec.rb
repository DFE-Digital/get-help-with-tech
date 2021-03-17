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

  describe '#check_answers' do
    let(:user) { create(:school_user) }
    let(:school) { user.school }
    let(:device_request) { create(:donated_device_request, :wants_laptops, :opt_in_all, :wants_full_amount, user: user, schools: [school.id]) }

    before do
      device_request
      sign_in_as user
    end

    it 'sets completed_at' do
      post :check_answers, params: { urn: school.urn }
      expect(device_request.reload.completed_at).to be_within(10.seconds).of(Time.zone.now)
    end
  end
end

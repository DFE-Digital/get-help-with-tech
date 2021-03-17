require 'rails_helper'

RSpec.describe ResponsibleBody::DonatedDevices::InterestController do
  let(:support_user) { create(:support_user) }
  let(:rb_user) { create(:trust_user) }
  let(:rb) { rb_user.responsible_body }

  actions = %w[
    create
    interest_confirmation
    all_or_some_schools
    select_schools
    device_types
    how_many_devices
    check_answers
  ]

  actions.each do |action|
    describe "##{action}" do
      context 'when support user impersonating' do
        before do
          create(:donated_device_request, responsible_body: rb)
          sign_in_as support_user
          impersonate rb_user
        end

        it 'returns forbidden' do
          post action, params: {
            donated_device_interest_form: { device_interest: 'asd' },
          }

          expect(response).to be_forbidden
        end
      end
    end
  end

  describe '#check_answers' do
    let(:user) { create(:trust_user) }
    let(:rb) { user.responsible_body }
    let(:device_request) { create(:donated_device_request, :wants_laptops, :opt_in_all, :wants_full_amount, user: user, responsible_body: rb, schools: rb.schools.pluck(:id)) }

    before do
      create(:school, responsible_body: rb)
      device_request
      sign_in_as user
    end

    it 'sets completed_at' do
      post :check_answers, params: { id: rb.id }
      expect(device_request.reload.completed_at).to be_within(10.seconds).of(Time.zone.now)
    end
  end
end

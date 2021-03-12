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
end

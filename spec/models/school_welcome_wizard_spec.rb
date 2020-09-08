require 'rails_helper'

RSpec.describe SchoolWelcomeWizard, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :step }
  end

  describe '#update_step!' do
    let(:school) { create(:school, :with_preorder_information) }
    let(:school_user) { create(:school_user, :new_visitor, school: school) }

    subject(:wizard) { school_user.school_welcome_wizard }

    context 'when the step is privacy' do
      before do
        wizard.privacy!
      end

      it 'moves to the allocation step' do
        wizard.update_step!
        expect(wizard.allocation?).to be true
      end

      it 'records when the privacy notice was seen' do
        Timecop.freeze(Time.zone.now) do
          wizard.update_step!
          expect(school_user.privacy_notice_seen_at).to eq(Time.zone.now)
        end
      end
    end

    context 'when the step is allocation' do
      before do
        wizard.allocation!
      end

      it 'moves to the order_your_own step' do
        wizard.update_step!
        expect(wizard.order_your_own?).to be true
      end
    end

    context 'when the step is order_your_own and user is the only school user' do
      before do
        wizard.order_your_own!
      end

      it 'moves to the will_you_order step' do
        wizard.update_step!
        expect(wizard.will_you_order?).to be true
      end
    end

    context 'when the step is order_your_own and user is not the only school user' do
      let(:additional_school_user) { create(:school_user, :new_visitor, school: school_user.school) }

      before do
        additional_school_user
        wizard.order_your_own!
      end

      it 'moves to the devices_you_can_order step' do
        wizard.update_step!
        expect(wizard.devices_you_can_order?).to be true
      end
    end

    context 'when the step is will_you_order and user chooses to order' do
      before do
        wizard.will_you_order!
      end

      it 'moves to the techsource_account step' do
        wizard.update_step!({ user_orders_devices: '1' })
        expect(wizard.techsource_account?).to be true
      end

      it 'records the choice and updates the user' do
        wizard.update_step!({ user_orders_devices: '1' })
        expect(wizard.user_orders_devices?).to be true
        expect(wizard.user.orders_devices?).to be true
      end
    end

    context 'when the step is will_you_order and user chooses not to order' do
      before do
        wizard.will_you_order!
      end

      it 'moves to the will_other_order step' do
        wizard.update_step!({ user_orders_devices: '0' })
        expect(wizard.will_other_order?).to be true
      end

      it 'records the choice and updates the user' do
        wizard.update_step!({ user_orders_devices: '0' })
        expect(wizard.user_orders_devices?).to be false
        expect(wizard.user.orders_devices?).to be false
      end
    end

    context 'when the step is will_you_order and user does not make a choice' do
      before do
        wizard.will_you_order!
      end

      it 'remains on the will_you_order step' do
        wizard.update_step!({ step: 'will_you_order' })
        expect(wizard.will_you_order?).to be true
      end

      it 'adds an error message' do
        wizard.update_step!({ step: 'will_you_order' })
        expect(wizard.errors.keys).to include(:user_orders_devices)
      end
    end

    context 'when the step is techsource_account' do
      before do
        wizard.techsource_account!
      end

      it 'moves to the will_other_order step' do
        wizard.update_step!
        expect(wizard.will_other_order?).to be true
      end
    end

    context 'when the step is will_other_order and the user chooses not to add a user' do
      before do
        wizard.will_other_order!
      end

      it 'moves to the devices_you_can_order step' do
        wizard.update_step!({ invite_user: 'no' })
        expect(wizard.devices_you_can_order?).to be true
      end
    end

    context 'when the step is will_other_order and the user chooses to add a user' do
      let(:new_user_attrs) { attributes_for(:school_user) }

      before do
        wizard.will_other_order!
      end

      it 'creates a new user' do
        expect {
          wizard.update_step!(new_user_attrs.merge({ invite_user: 'yes' }))
        }.to change { User.count }.by(1)
      end

      it 'populates the new user with the correct attributes' do
        wizard.update_step!(new_user_attrs.merge({ invite_user: 'yes' }))
        user = User.last
        expect(user.full_name).to eq(new_user_attrs[:full_name])
        expect(user.email_address).to eq(new_user_attrs[:email_address])
        expect(user.telephone).to eq(new_user_attrs[:telephone])
        expect(user.orders_devices).to eq(new_user_attrs[:orders_devices])
        expect(user.school).to eq(school_user.school)
      end

      it 'sends an email to the new user' do
        expect {
          wizard.update_step!(new_user_attrs.merge({ invite_user: 'yes' }))
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).once
      end

      it 'moves to the devices_you_can_order step' do
        wizard.update_step!(new_user_attrs.merge({ invite_user: 'yes' }))
        expect(wizard.devices_you_can_order?).to be true
      end
    end

    context 'when the step is will_other_order and the user enters incomplete user details' do
      let(:new_user_attrs) { attributes_for(:school_user) }

      before do
        wizard.will_other_order!
      end

      it 'adds error messages' do
        wizard.update_step!(new_user_attrs.slice(:full_name).merge({ invite_user: 'yes' }))
        expect(wizard.errors.keys).to include(:email_address, :orders_devices)
      end

      it 'remains on the will_other_order step' do
        wizard.update_step!(new_user_attrs.slice(:full_name).merge({ invite_user: 'yes' }))
        expect(wizard.will_other_order?).to be true
      end
    end

    context 'when the step is will_other_order and the user does not make a choice' do
      before do
        wizard.will_other_order!
      end

      it 'adds an error message' do
        wizard.update_step!
        expect(wizard.errors.keys).to include(:invite_user)
      end

      it 'remains on the will_other_order step' do
        wizard.update_step!
        expect(wizard.will_other_order?).to be true
      end
    end

    context 'when the step is devices_you_can_order and will_need_chromebooks has not been answered' do
      before do
        wizard.devices_you_can_order!
        school.preorder_information.update!(will_need_chromebooks: nil)
      end

      it 'moves to the chromebooks step' do
        wizard.update_step!
        expect(wizard.chromebooks?).to be true
      end
    end

    context 'when the step is devices_you_can_order and will_need_chromebooks has already been answered' do
      before do
        wizard.devices_you_can_order!
        school.preorder_information.update!(will_need_chromebooks: 'yes')
      end

      it 'moves to the chromebooks step' do
        wizard.update_step!
        expect(wizard.chromebooks?).to be true
      end
    end

    context 'when the step is chromebooks and the school needs chromebooks' do
      let(:request) { attributes_for(:preorder_information, :needs_chromebooks) }

      before do
        wizard.chromebooks!
      end

      it 'updates the preorder_information with the form details' do
        wizard.update_step!(request)
        expect(school.preorder_information.will_need_chromebooks).to eq(request[:will_need_chromebooks])
        expect(school.preorder_information.school_or_rb_domain).to eq(request[:school_or_rb_domain])
        expect(school.preorder_information.recovery_email_address).to eq(request[:recovery_email_address])
      end

      it 'moves to the what_happens_next step' do
        wizard.update_step!(request)
        expect(wizard.what_happens_next?).to be true
      end
    end

    context 'when the step is chromebooks and the school needs chromebooks but doesnt complete the form' do
      let(:bad_request) { { will_need_chromebooks: 'yes', school_or_rb_domain: '', recovery_email_address: '' } }

      before do
        wizard.chromebooks!
      end

      it 'adds validation errors' do
        wizard.update_step!(bad_request)
        expect(wizard.errors.keys).to include(:school_or_rb_domain, :recovery_email_address)
      end

      it 'does not change step' do
        wizard.update_step!(bad_request)
        expect(wizard.chromebooks?).to be true
      end
    end

    context 'when the step is chromebooks and the school does not need chromebooks' do
      let(:request) { attributes_for(:preorder_information, :does_not_need_chromebooks) }

      before do
        wizard.chromebooks!
      end

      it 'updates the preorder_information with the form details' do
        wizard.update_step!(request)
        expect(school.preorder_information.will_need_chromebooks).to eq('no')
      end

      it 'moves to the what_happens_next step' do
        wizard.update_step!(request)
        expect(wizard.what_happens_next?).to be true
      end
    end

    context 'when the step is chromebooks and the school does not know if it needs chromebooks' do
      let(:request) { { will_need_chromebooks: 'i_dont_know' } }

      before do
        wizard.chromebooks!
      end

      it 'updates the preorder_information with the form details' do
        wizard.update_step!(request)
        expect(school.preorder_information.will_need_chromebooks).to be_nil
      end

      it 'moves to the what_happens_next step' do
        wizard.update_step!(request)
        expect(wizard.what_happens_next?).to be true
      end
    end

    context 'when the step is what_happens_next' do
      before do
        wizard.what_happens_next!
      end

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end
    end
  end
end

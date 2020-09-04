require 'rails_helper'

RSpec.describe SchoolWelcomeWizard, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :step }
  end

  describe '#update_step!' do
    let(:school_user) { create(:school_user, :new_visitor) }

    subject(:wizard) { school_user.school_welcome_wizard }

    context 'when the step is welcome' do
      before do
        wizard.welcome!
      end

      it 'moves to the privacy step' do
        wizard.update_step!
        expect(wizard.privacy?).to be true
      end
    end

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

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end
    end

    context 'when the step is will_you_order and user chooses to order' do
      before do
        wizard.will_you_order!
      end

      it 'moves to the techsource_account step' do
        wizard.update_step!({ orders_devices: '1' })
        expect(wizard.techsource_account?).to be true
      end

      it 'records the choice and updates the user' do
        wizard.update_step!({ orders_devices: '1' })
        expect(wizard.orders_devices?).to be true
        expect(wizard.user.orders_devices?).to be true
      end
    end

    context 'when the step is will_you_order and user chooses not to order' do
      before do
        wizard.will_you_order!
      end

      it 'moves to the completed step' do
        wizard.update_step!({ orders_devices: '0' })
        expect(wizard.complete?).to be true
      end

      it 'records the choice and updates the user' do
        wizard.update_step!({ orders_devices: '0' })
        expect(wizard.orders_devices?).to be false
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
        expect(wizard.errors.keys).to include(:orders_devices)
      end
    end

    context 'when the step is techsource_account' do
      before do
        wizard.techsource_account!
      end

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end
    end
  end
end

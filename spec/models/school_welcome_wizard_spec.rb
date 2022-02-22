require 'rails_helper'

RSpec.describe SchoolWelcomeWizard, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of :step }
  end

  describe '#update_step!' do
    let(:school) { create(:school, :with_preorder_information, :manages_orders) }
    let(:school_user) { create(:school_user, :new_visitor, school:) }

    subject(:wizard) { school_user.welcome_wizard_for(school) }

    context 'when the step is allocation' do
      before do
        wizard.allocation!
      end

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end

      context 'has devices available to order' do
        let(:school) { create(:school, :with_preorder_information, :manages_orders, laptops: [2, 1, 0]) }

        context 'user orders devices' do
          let(:school_user) { create(:school_user, :new_visitor, school:, orders_devices: true) }

          it 'moves to the completed step' do
            wizard.update_step!
            expect(wizard.complete?).to be true
          end
        end

        context 'user does not order devices' do
          let(:school_user) { create(:school_user, :new_visitor, school:, orders_devices: false) }

          it 'moves to the completed step' do
            wizard.update_step!
            expect(wizard.complete?).to be true
          end
        end
      end
    end

    context 'when the step is allocation and user orders devices' do
      let(:school_user) { create(:school_user, :new_visitor, school:, orders_devices: true) }

      before do
        wizard.allocation!
      end

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end
    end

    context 'when the step is allocation and user is not the only school user' do
      let(:additional_school_user) { create(:school_user, :new_visitor, school: school_user.school) }

      before do
        additional_school_user
        wizard.allocation!
      end

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end
    end
  end
end

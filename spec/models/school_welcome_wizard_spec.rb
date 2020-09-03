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

      it 'moves to the completed step' do
        wizard.update_step!
        expect(wizard.complete?).to be true
      end

      it 'records when the privacy notice was seen' do
        Timecop.freeze(Time.zone.now) do
          wizard.update_step!
          expect(school_user.privacy_notice_seen_at).to eq(Time.zone.now)
        end
      end
    end
  end
end

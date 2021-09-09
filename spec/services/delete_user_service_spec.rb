require 'rails_helper'

RSpec.describe DeleteUserService do
  describe '#delete!' do
    context 'techsource_account_confirmed_at set' do
      let(:user) { create(:local_authority_user, :with_a_confirmed_techsource_account) }

      before do
        described_class.delete!(user)
      end

      it 'soft deletes the user' do
        expect(user.reload.deleted_at).to be_present
      end
    end

    context 'techsource_account_confirmed_at NOT set' do
      let(:user) { create(:local_authority_user) }
      let(:school_user) { create(:school_user) }

      before do
        @wizard = school_user.school_welcome_wizards.first
        @wizard.update!(invited_user_id: user.id)

        described_class.delete!(user)
      end

      it 'hard deletes the user' do
        expect(User.find_by(id: user.id)).to be_nil
      end

      it 'nullifies the welcome wizard invite_user_id' do
        expect(@wizard.reload.invited_user_id).to be_nil
      end
    end
  end
end

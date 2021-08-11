require 'rails_helper'

RSpec.describe DeleteUserService do
  describe '#delete!' do
    before do
      described_class.delete!(user)
    end

    context 'techsource_account_confirmed_at set' do
      let(:user) { create(:local_authority_user, :with_a_confirmed_techsource_account) }

      it 'soft deletes the user' do
        expect(user.reload.deleted_at).to be_present
      end
    end

    context 'techsource_account_confirmed_at NOT set' do
      let(:user) { create(:local_authority_user) }

      it 'hard deletes the user' do
        expect(User.find_by(id: user.id)).to be_nil
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Support::PrivilegedUsersController do
  let(:support_user) { create(:support_user, role: 'third_line') }

  before do
    sign_in_as support_user
  end

  describe '#index' do
    context 'when support user' do
      let(:support_user) { create(:support_user) }

      it 'is not successful' do
        get :index
        expect(response).not_to be_successful
      end
    end

    context 'when third line support user' do
      it 'is successful' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe '#create' do
    it 'creates privileged user' do
      expect {
        post :create, params: {
          support_privileged_user_form: {
            full_name: 'John Doe',
            email_address: 'john.doe@digital.education.gov.uk',
            privileges: %w[support],
          },
        }
      }.to change(User, :count).by(1)

      record = User.last

      expect(record.full_name).to eql('John Doe')
      expect(record.email_address).to eql('john.doe@digital.education.gov.uk')
      expect(record.is_support).to be_truthy
      expect(record.is_computacenter).to be_falsey
    end
  end

  describe '#destroy' do
    let!(:other_support_user) { create(:support_user) }

    it 'removes privileges from user' do
      expect {
        delete :destroy, params: { id: other_support_user.id }
      }.to change { other_support_user.reload.is_support }.from(true).to(false)
    end
  end

  describe '#new' do
    it 'is successful' do
      get :new
      expect(response).to be_successful
    end
  end

  describe '#show' do
    let!(:other_support_user) { create(:support_user) }

    it 'is successful' do
      get :show, params: { id: other_support_user.id }
      expect(response).to be_successful
    end
  end
end

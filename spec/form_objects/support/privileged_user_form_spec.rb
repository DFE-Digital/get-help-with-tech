require 'rails_helper'

RSpec.describe Support::PrivilegedUserForm do
  describe 'validations' do
    before do
      form.valid?
    end

    context 'when full_name is blank' do
      subject(:form) { described_class.new(email_address: '', privileges: []) }

      it 'has errors' do
        expect(form.errors[:full_name]).to be_present
      end
    end

    context 'when email_address is blank' do
      subject(:form) { described_class.new(email_address: '', privileges: []) }

      it 'has errors' do
        expect(form.errors[:email_address]).to be_present
      end
    end

    context 'when email_address is not from valid domain' do
      subject(:form) { described_class.new(email_address: 'user@example.com', privileges: []) }

      it 'has errors' do
        expect(form.errors[:email_address]).to be_present
      end
    end

    context 'when email_address is from valid domain' do
      ['user@computacenter.com',
       'user@digital.education.gov.uk',
       'user@education.gov.uk'].each do |email|
        subject(:form) { described_class.new(email_address: email, privileges: []) }

        it "does not have errors for #{email}" do
          expect(form.errors[:email_address]).not_to be_present
        end
      end
    end

    context 'when email is taken' do
      let!(:existing_user) { create(:support_user) }

      subject(:form) { described_class.new(email_address: existing_user.email_address, privileges: []) }

      it 'has errors' do
        expect(form.errors[:email_address]).to be_present
      end
    end

    context 'when no privileges selected' do
      subject(:form) { described_class.new(email_address: '', privileges: []) }

      it 'has errors' do
        expect(form.errors[:privileges]).to be_present
      end
    end

    context 'when injecting custom privilege' do
      subject(:form) { described_class.new(email_address: '', privileges: %w[foo]) }

      it 'has errors' do
        expect(form.errors[:privileges]).to be_present
      end
    end
  end

  describe '#create_user!' do
    subject(:form) { described_class.new(full_name: 'some body', email_address: 'user@digital.education.gov.uk', privileges: %w[support computacenter]) }

    it 'sets up privileges' do
      expect {
        form.create_user!
      }.to change(User, :count).by(1)

      user = User.last

      expect(user.is_support?).to be_truthy
      expect(user.is_computacenter?).to be_truthy
    end
  end
end

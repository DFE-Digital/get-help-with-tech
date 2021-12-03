require 'rails_helper'

RSpec.describe CreateAdminUsersService do
  let(:new_email_address) { 'homer.simpson@thesimpsons.com' }
  let!(:existing_user) { create(:user) }

  context 'single email' do
    it 'only accepts :supplier or :support' do
      expect {
        CreateAdminUsersService.new(new_email_address, :superadmin).create!
      }.to raise_error(RuntimeError, 'user_type must be :support or :supplier')
    end

    context 'no type supplied' do
      it 'creates a new user' do
        expect {
          CreateAdminUsersService.new(new_email_address).create!
        }.to change { User.count }.by(1)
      end

      it 'sets is_support to true' do
        CreateAdminUsersService.new(new_email_address).create!
        u = User.find_by_email_address(new_email_address)

        expect(u.email_address).to eq(new_email_address)
        expect(u.is_support).to be true
        expect(u.is_computacenter).to be false
      end

      it 'does not create a new user if they exist' do
        expect {
          CreateAdminUsersService.new(existing_user.email_address).create!
        }.not_to(change { User.count })
      end

      it 'updates existing user to have is_support true' do
        expect {
          CreateAdminUsersService.new(existing_user.email_address).create!
        }.to(change { User.find_by_email_address(existing_user.email_address).is_support }.from(false).to(true))
      end

      it 'downcases the email address' do
        CreateAdminUsersService.new('BaRt.SiMpSoN@TheSimpsons.com').create!
        expect(User.find_by_email_address('bart.simpson@thesimpsons.com').email_address).to eq('bart.simpson@thesimpsons.com')
      end

      it 'trims the email address of spaces' do
        CreateAdminUsersService.new(' BaRt.SiMpSoN@TheSimpsons.com  ').create!
        expect(User.find_by_email_address('bart.simpson@thesimpsons.com').email_address).to eq('bart.simpson@thesimpsons.com')
      end
    end

    context 'supplier type' do
      it 'sets is_computacenter to true' do
        CreateAdminUsersService.new(new_email_address, :supplier).create!
        u = User.find_by_email_address(new_email_address)
        expect(u.email_address).to eq(new_email_address)
        expect(u.is_computacenter).to be true
        expect(u.is_support).to be false
      end
    end

    context 'support type' do
      it 'sets is_support to true' do
        CreateAdminUsersService.new(new_email_address, :support).create!
        u = User.find_by_email_address(new_email_address)
        expect(u.email_address).to eq(new_email_address)
        expect(u.is_support).to be true
        expect(u.is_computacenter).to be false
      end
    end
  end

  context 'multiple emails' do
    let(:new_email_address_2) { 'maggie.simpson@thesimpsons.com' }

    context 'no type supplied' do
      it 'creates multiple new users' do
        expect {
          CreateAdminUsersService.new([new_email_address, new_email_address_2]).create!
        }.to change { User.count }.by(2)
      end

      it 'sets is_support to true' do
        CreateAdminUsersService.new([new_email_address, new_email_address_2]).create!

        u = User.find_by_email_address(new_email_address)
        expect(u.email_address).to eq(new_email_address)
        expect(u.is_support).to be true
        expect(u.is_computacenter).to be false

        u2 = User.find_by_email_address(new_email_address_2)
        expect(u2.email_address).to eq(new_email_address_2)
        expect(u2.is_support).to be true
        expect(u2.is_computacenter).to be false
      end

      it 'updates existing users' do
        expect {
          CreateAdminUsersService.new([new_email_address, existing_user.email_address]).create!
        }.to change { User.count }.by(1)
      end

      it 'updates existing users to have is_support true' do
        expect {
          CreateAdminUsersService.new([new_email_address, existing_user.email_address]).create!
        }.to(change { User.find_by_email_address(existing_user.email_address).is_support }.from(false).to(true))
      end
    end

    context 'supplier type' do
      it 'sets is_computacenter to true' do
        CreateAdminUsersService.new([new_email_address, existing_user.email_address], :supplier).create!

        u = User.find_by_email_address(new_email_address)
        expect(u.email_address).to eq(new_email_address)
        expect(u.is_computacenter).to be true
        expect(u.is_support).to be false

        u2 = User.find_by_email_address(existing_user.email_address)
        expect(u2.email_address).to eq(existing_user.email_address)
        expect(u.is_computacenter).to be true
        expect(u.is_support).to be false
      end
    end

    context 'support type' do
      it 'sets is_support to true' do
        CreateAdminUsersService.new([new_email_address, existing_user.email_address], :support).create!

        u = User.find_by_email_address(new_email_address)
        expect(u.email_address).to eq(new_email_address)
        expect(u.is_support).to be true
        expect(u.is_computacenter).to be false

        u2 = User.find_by_email_address(existing_user.email_address)
        expect(u2.email_address).to eq(existing_user.email_address)
        expect(u.is_support).to be true
        expect(u.is_computacenter).to be false
      end
    end
  end
end

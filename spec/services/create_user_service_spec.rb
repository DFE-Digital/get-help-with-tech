require 'rails_helper'

RSpec.describe CreateUserService, type: :model do
  let(:trust) { create(:trust) }

  subject(:service) { described_class.new }

  context 'for an existing responsible body' do
    before do
      Timecop.freeze(Date.new(2020, 7, 1)) do
        service.call(full_name: 'A B', email_address: 'ab@example.com', responsible_body_name: trust.name)
      end
    end

    it 'creates a new user attached to the responsible body' do
      expect(User.count).to eq(1)
    end

    it 'creates a user with the passed attributes' do
      user = User.first
      expect(user.full_name).to eq('A B')
      expect(user.email_address).to eq('ab@example.com')
      expect(user.responsible_body).to eq(trust)
    end

    it 'creates an approved user' do
      expect(User.first.approved_at).to eq(Date.new(2020, 7, 1))
    end
  end

  context 'for a non-existent responsible body' do
    it 'throws an error' do
      expect {
        service.call(responsible_body_name: 'made up', full_name: 'A B', email_address: 'ab@example.com')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when there is an issue with the user attributes' do
    it 'throws an error' do
      expect {
        service.call(email_address: 'a', full_name: 'A B', responsible_body_name: trust.name)
      }.to raise_error(ActiveRecord::RecordInvalid, /'Email address' is too short/)
    end
  end
end

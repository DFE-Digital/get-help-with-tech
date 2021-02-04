require 'rails_helper'

RSpec.describe Support::UserSearchForm do
  before do
    create(:school_user, email_address: 'user1@example.com')
  end

  describe '#results' do
    context 'when there is a match' do
      subject(:form) { described_class.new(email_address_or_full_name: 'user1@example.com', scope: User) }

      it 'returns match' do
        expect(form.results.size).to be(1)
        expect(form.results.map(&:email_address)).to include('user1@example.com')
      end
    end

    context 'when there is no match' do
      subject(:form) { described_class.new(email_address_or_full_name: 'user2@example.com', scope: User) }

      it 'returns empty' do
        expect(form.results.size).to be(0)
      end
    end
  end

  describe '#related_results' do
    context 'when there is a match' do
      subject(:form) { described_class.new(email_address_or_full_name: 'user1@example.com', scope: User) }

      it 'returns empty' do
        expect(form.related_results.size).to be(0)
      end
    end

    context 'when there is no match' do
      subject(:form) { described_class.new(email_address_or_full_name: 'user2@example.com', scope: User) }

      it 'returns related results' do
        expect(form.related_results.size).to be(1)
        expect(form.related_results.map(&:email_address)).to include('user1@example.com')
      end
    end
  end
end

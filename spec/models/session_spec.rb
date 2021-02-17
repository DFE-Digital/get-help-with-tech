require 'rails_helper'

RSpec.describe Session do
  describe '#expired?' do
    context 'when expires_at in the past' do
      subject(:model) { described_class.new(expires_at: 10.minutes.ago) }

      it 'return true' do
        expect(model.expired?).to be_truthy
      end
    end

    context 'when expires_at in the future' do
      subject(:model) { described_class.new(expires_at: 10.minutes.from_now) }

      it 'return false' do
        expect(model.expired?).to be_falsey
      end
    end
  end
end

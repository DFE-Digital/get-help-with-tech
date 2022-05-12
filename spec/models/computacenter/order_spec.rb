require 'rails_helper'

RSpec.describe Computacenter::Order, type: :model do
  let(:order) { build_stubbed(:computacenter_order) }

  it 'returns an Order' do
    expect(order).to be_a(described_class)
  end

  describe '.is_return' do
    it 'returns orders that are returns' do
      order = create(:computacenter_order, is_return: true)

      expect(described_class.is_return).to include(order)
    end

    it 'returns orders that are not returns' do
      order = create(:computacenter_order, is_return: false)

      expect(described_class.is_not_return).to include(order)
    end
  end

  describe '.is_not_return' do
    it 'returns orders that are not returns' do
      order = create(:computacenter_order, is_return: false)

      expect(described_class.is_not_return).to include(order)
    end

    it 'returns orders that are returns' do
      order = create(:computacenter_order, is_return: true)

      expect(described_class.is_return).to include(order)
    end
  end
end

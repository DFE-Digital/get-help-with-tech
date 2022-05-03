require 'rails_helper'

RSpec.describe Computacenter::Order, type: :model do
  let(:order) { build_stubbed(:computacenter_order) }

  it 'returns an Order' do
    expect(order).to be_a(described_class)
  end
end

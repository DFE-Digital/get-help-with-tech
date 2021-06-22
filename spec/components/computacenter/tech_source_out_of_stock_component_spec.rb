require 'rails_helper'

RSpec.describe Computacenter::TechSourceOutOfStockComponent, type: :component do
  it 'renders' do
    expect(render_inline(described_class.new)).to have_text('out of stock')
  end
end

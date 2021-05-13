require 'rails_helper'

RSpec.describe LinkToSurveyComponent, type: :component do
  before { render_inline(described_class.new(organisation: organisation)) }

  context 'nil organisation' do
    let(:organisation) { nil }

    specify { expect(rendered_component).to have_link('Complete a survey') }
  end

  context 'responsible body' do
    let(:organisation) { build(:local_authority) }

    specify { expect(rendered_component).to have_link('Complete a survey') }
  end

  context 'state school' do
    let(:organisation) { build(:school) }

    specify { expect(rendered_component).to have_link('Complete a survey') }
  end

  context 'independent special school' do
    let(:organisation) { build(:iss_provision) }

    specify { expect(rendered_component).to be_blank }
  end

  context 'social care leaver' do
    let(:organisation) { build(:scl_provision) }

    specify { expect(rendered_component).to be_blank }
  end
end

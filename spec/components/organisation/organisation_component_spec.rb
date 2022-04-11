require 'rails_helper'

RSpec.describe Organisation::OrganisationComponent, type: :component do
  let(:responsible_body) { build(:local_authority, name: 'Buckinghamshire') }

  subject { render_inline(described_class.new(organisation:)) }

  context 'responsible body' do
    let(:organisation) { responsible_body }

    it { is_expected.to have_link("Buckinghamshire \u2013 state schools and colleges") }
  end

  context 'state school' do
    let(:organisation) { build(:school, name: 'Royal Grammar School for Boys') }

    it { is_expected.to have_link('Royal Grammar School for Boys') }
  end

  context 'independent special school' do
    let(:organisation) { build(:iss_provision, responsible_body:) }

    it { is_expected.to have_link("Buckinghamshire \u2013 state\u2011funded pupils at independent special schools and alternative provision") }
  end

  context 'social care leaver' do
    let(:organisation) { build(:scl_provision, responsible_body:) }

    it { is_expected.to have_link("Buckinghamshire \u2013 social care leavers") }
  end
end

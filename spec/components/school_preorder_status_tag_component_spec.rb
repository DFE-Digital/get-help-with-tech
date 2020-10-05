require 'rails_helper'

RSpec.describe SchoolPreorderStatusTagComponent do
  subject(:component) { described_class.new(school: school, viewer: viewer) }

  let(:school) { instance_double('School', preorder_status_or_default: 'rb_can_order') }
  let(:viewer) { nil }

  describe '#text' do
    context 'when RB can order' do
      it 'returns RB can order' do
        expect(component.text).to eql('Responsible body can order')
      end

      context 'when viewer is an RB' do
        let(:school) { instance_double('School', perceived_state: 'rb_can_order') }
        let(:viewer) { LocalAuthority.new }

        it 'returns You can order' do
          expect(component.text).to eql('You can order')
        end
      end
    end
  end
end

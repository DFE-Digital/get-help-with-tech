require 'rails_helper'

RSpec.describe SchoolPreorderStatusTagComponent do
  subject(:component) { described_class.new(school: school, viewer: viewer) }

  let(:school) { instance_double('School', preorder_status_or_default: 'rb_can_order', orders_managed_by_school?: false) }
  let(:viewer) { nil }

  describe '#text' do
    context 'when RB can order' do
      it 'returns RB can order' do
        expect(component.text).to eql('Responsible body can order')
      end

      context 'when viewer is an RB' do
        let(:school) { instance_double('School', preorder_status_or_default: 'rb_can_order', orders_managed_by_school?: false) }
        let(:viewer) { LocalAuthority.new }

        it 'returns You can order' do
          expect(component.text).to eql('You can order')
        end
      end
    end

    context 'when school is managed centrally' do
      context 'when the RB has ordered' do
        let(:school) { instance_double('School', preorder_status_or_default: 'ordered', orders_managed_by_school?: false) }

        it 'returns RB has ordered' do
          expect(component.text).to eql('Responsible body has ordered')
        end
      end
    end

    context 'when school manages orders' do
      let(:school) { instance_double('School', preorder_status_or_default: 'ordered', orders_managed_by_school?: true) }

      context 'when the school has ordered' do
        it 'returns school has ordered' do
          expect(component.text).to eql('School has ordered')
        end
      end
    end
  end
end

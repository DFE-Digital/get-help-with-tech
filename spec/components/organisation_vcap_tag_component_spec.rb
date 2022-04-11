require 'rails_helper'

RSpec.describe OrganisationVcapTagComponent do
  subject(:component) { described_class.new(organisation) }

  describe '#text' do
    context 'when the organisation is an RB' do
      let(:organisation) { create(:local_authority, vcap:) }

      context 'when the RB sets a vcap' do
        let(:vcap) { true }

        it 'returns YES' do
          expect(component.text).to eq('YES')
        end
      end

      context 'when the RB sets no vcap' do
        let(:vcap) { false }

        it 'returns NONE' do
          expect(component.text).to eq('NONE')
        end
      end
    end

    context 'when the organisation is a school' do
      let(:rb) { create(:local_authority, :vcap) }
      let(:organisation) { create(:school, management, responsible_body: rb) }

      context 'when the school is part of a vcap' do
        let(:management) { :centrally_managed }

        it 'returns YES' do
          expect(component.text).to eq('YES')
        end
      end

      context 'when the school is not part of a vcap' do
        let(:management) { :manages_orders }

        it 'returns NONE' do
          expect(component.text).to eq('NONE')
        end
      end
    end
  end

  describe '#color' do
    context 'when the organisation is an RB' do
      let(:organisation) { create(:local_authority, vcap:) }

      context 'when the RB sets a vcap' do
        let(:vcap) { true }

        it 'returns :green' do
          expect(component.color).to eq(:green)
        end
      end

      context 'when the RB sets no vcap' do
        let(:vcap) { false }

        it 'returns :yellow' do
          expect(component.color).to eq(:yellow)
        end
      end
    end

    context 'when the organisation is a school' do
      let(:rb) { create(:trust, :vcap) }
      let(:organisation) { create(:school, management, responsible_body: rb) }

      context 'when the school is part of a vcap' do
        let(:management) { :centrally_managed }

        it 'returns :green' do
          expect(component.color).to eq(:green)
        end
      end

      context 'when the school is not part of a vcap' do
        let(:management) { :manages_orders }

        it 'returns :yellow' do
          expect(component.color).to eq(:yellow)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Computacenter::SoldToShipToUpdater do
  let(:responsible_body) { create(:local_authority, computacenter_reference: nil) }
  let(:school) { create(:school, :manages_orders, :with_std_device_allocation, responsible_body: responsible_body, computacenter_reference: nil) }

  describe '#update_sold_to!' do

    subject(:updater) { described_class.new(responsible_body) }

    before do
      responsible_body.computacenter_change_amended!
    end

    it 'updates the computacenter_reference' do
      updater.update_sold_to!('12345678')
      expect(responsible_body.computacenter_reference).to eq('12345678')
    end

    it 'sets computacenter_change to none' do
      updater.update_sold_to!('12345678')
      expect(responsible_body.computacenter_change_none?).to be true
    end

    context 'when schools have ship-to references' do
      before do
        stub_computacenter_outgoing_api_calls
        school.update!(computacenter_reference: '80000001')
      end
      it 'sends cap updates for its schools' do
        updater.update_sold_to!('12345678')
        expect(school.reload.std_device_allocation.cap_update_request_timestamp).to be_within(2.seconds).of(Time.zone.now)
      end
    end
  end

  describe '#update_ship_to!' do

    subject(:updater) { described_class.new(school) }

    it 'updates the computacenter_reference' do
      updater.update_ship_to!('87654321')
      expect(school.computacenter_reference).to eq('87654321')
    end

    it 'sets computacenter_change to none' do
      updater.update_ship_to!('87654321')
      expect(school.computacenter_change_none?).to be true
    end

    context 'when the responsible body has a sold-to reference' do
      before do
        stub_computacenter_outgoing_api_calls
        responsible_body.update!(computacenter_reference: '12345678')
      end

      it 'sends cap updates for the school' do
        updater.update_ship_to!('87654321')
        expect(school.reload.std_device_allocation.cap_update_request_timestamp).to be_within(2.seconds).of(Time.zone.now)
      end
    end
  end
end

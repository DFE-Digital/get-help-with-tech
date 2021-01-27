require 'rails_helper'

RSpec.describe SchoolSearchForm do
  let(:school) { create(:school) }
  let(:closed_school) { create(:school, status: :closed) }

  describe '#array_of_identifiers' do
    subject(:form) do
      described_class.new(identifiers: "   123  \r\ \r\n456\r\n", search_type: 'multiple')
    end

    it 'returns correct array of identifiers' do
      expect(form.array_of_identifiers).to eql(%w[123 456])
    end
  end

  describe '#missing_identifiers' do
    subject(:form) do
      described_class.new(identifiers: "   #{school.urn}  \r\ \r\n456\r\n", search_type: 'multiple')
    end

    it 'returns array of identifiers with no matches' do
      expect(form.missing_identifiers).to eql(%w[456])
    end
  end

  describe '#schools' do
    context 'given identifiers' do
      subject(:form) do
        described_class.new(identifiers: "#{school.urn}\r\n#{closed_school.urn}\r\n", search_type: 'multiple')
      end

      it 'only includes schools matching those identifiers which are not closed' do
        expect(form.schools.map(&:urn)).to eq([school.urn])
      end
    end

    context 'given a responsible_body_id' do
      let!(:other_school_from_same_rb) { create(:school, responsible_body: school.responsible_body) }
      let!(:open_school_from_different_rb) { create(:school, responsible_body: create(:local_authority)) }

      subject(:form) do
        described_class.new(responsible_body_id: school.responsible_body_id, search_type: 'responsible_body_or_order_state')
      end

      it 'only includes schools matching that responsible_body_id which are not closed' do
        expect(form.schools.map(&:urn)).to include(school.urn, other_school_from_same_rb.urn)
        expect(form.schools.map(&:urn)).not_to include(open_school_from_different_rb.urn)
      end
    end

    context 'given an order_state' do
      let!(:school_that_can_order) { create(:school, :in_lockdown) }

      before do
        create(:school, :can_order_for_specific_circumstances)
        create(:school, :in_lockdown, status: :closed)
      end

      subject(:form) do
        described_class.new(order_state: 'can_order', search_type: 'responsible_body_or_order_state')
      end

      it 'only includes schools matching that order_state which are not closed' do
        expect(form.schools.map(&:urn)).to eq([school_that_can_order.urn])
      end
    end
  end

  describe '#csv_filename' do
    let(:urns) { nil }
    let(:responsible_body_id) { nil }
    let(:order_state) { nil }
    let(:form) { SchoolSearchForm.new(identifiers: urns, responsible_body_id: responsible_body_id, order_state: order_state, search_type: 'multiple') }
    let(:expected_timestamp) { Time.zone.now.utc.iso8601 }

    before do
      Timecop.travel(Time.zone.local(2020, 11, 27, 23, 0, 0))
    end

    context 'when no search params were given' do
      it 'returns allocations-(timestamp).csv' do
        expect(form.csv_filename).to eq("allocations-#{expected_timestamp}.csv")
      end
    end

    context 'when a responsible_body_id was given' do
      let(:responsible_body_id) { 1234 }

      it 'includes RB-(responsible_body_id)' do
        expect(form.csv_filename).to include('RB-1234')
      end
    end

    context 'when an order_state was given' do
      let(:order_state) { 'my_order_state' }

      it 'includes the order_state' do
        expect(form.csv_filename).to include('my_order_state')
      end
    end

    context 'when URNs are given' do
      let(:urns) { "101111\r\n101222\r\n101333\r\n" }

      it 'includes (number of urns)' do
        expect(form.csv_filename).to include('3')
      end
    end
  end
end

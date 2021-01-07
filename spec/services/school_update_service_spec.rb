require 'rails_helper'

RSpec.describe SchoolUpdateService, type: :model do
  subject(:service) { described_class.new }

  describe 'importing schools from staging' do
    let!(:local_authority) { create(:local_authority, name: 'Camden') }
    let!(:school) { create(:school, urn: '103001', responsible_body: local_authority) }

    context 'data update timestamps' do
      it 'updates the DataUpdateRecord timestamp for schools' do
        t = Time.zone.now
        Timecop.freeze(t) do
          service.update_schools
          expect(DataStage::DataUpdateRecord.last_update_for(:schools)).to be_within(1.second).of(t)
        end
      end

      it 'only applies changes since the last update' do
        Timecop.travel(6.hours.ago)
        create(:staged_school, urn: 103_001, responsible_body_name: 'Camden')
        Timecop.return

        Timecop.travel(2.hours.ago)
        DataStage::DataUpdateRecord.updated!(:schools)
        Timecop.return

        school_attrs = school.attributes.symbolize_keys

        service.update_schools

        expect(school.reload).to have_attributes(
          urn: school_attrs[:urn],
          name: school_attrs[:name],
          responsible_body_id: local_authority.id,
          address_1: school_attrs[:address_1],
          address_2: school_attrs[:address_2],
          address_3: school_attrs[:address_3],
          town: school_attrs[:town],
          postcode: school_attrs[:postcode],
          phase: school_attrs[:phase],
          establishment_type: school_attrs[:establishment_type],
          status: school_attrs[:status],
        )
      end
    end

    context 'when a school already exists' do
      let!(:staged_school) { create(:staged_school, urn: 103_001, responsible_body_name: 'Camden') }

      it 'updates the existing school record' do
        service.update_schools

        expect(school.reload).to have_attributes(
          urn: 103_001,
          name: staged_school.name,
          responsible_body_id: local_authority.id,
          address_1: staged_school.address_1,
          address_2: staged_school.address_2,
          address_3: staged_school.address_3,
          town: staged_school.town,
          postcode: staged_school.postcode,
          phase: staged_school.phase,
          establishment_type: staged_school.establishment_type,
          status: staged_school.status,
        )
      end
    end
  end

  describe '#create_school' do
    let!(:staged_school) { create(:staged_school, urn: 103_001, responsible_body_name: 'Camden') }

    before do
      create(:local_authority, name: 'Camden')
    end

    it 'creates school record' do
      expect {
        service.send(:create_school, staged_school)
      }.to change(School, :count).by(1)
    end
  end
end

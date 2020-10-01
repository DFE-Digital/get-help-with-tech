require 'rails_helper'

RSpec.describe SchoolUpdateService, type: :model do
  describe 'importing schools from staging' do
    let(:service) { subject }
    let!(:local_authority) { create(:local_authority, name: 'Camden') }
    let!(:staged_school) { create(:staged_school, urn: 103_001, responsible_body_name: 'Camden') }

    context 'data update timestamps' do
      it 'updates the DataUpdateRecord timestamp for schools' do
        Timecop.freeze do
          service.update_schools
          expect(Staging::DataUpdateRecord.last_update_for(:schools)).to eq(Time.zone.now)
        end
      end

      it 'only applies changes since the last update' do
        Timecop.travel(6.hours.ago)
        create(:staged_school, urn: 104_001, responsible_body_name: 'Camden')
        Timecop.return

        Timecop.travel(2.hours.ago)
        Staging::DataUpdateRecord.updated!(:schools)
        Timecop.return

        expect {
          service.update_schools
        }.to change { School.count }.by(1)

        expect(School.last).to have_attributes(
          urn: staged_school.urn,
          name: staged_school.name,
          responsible_body_id: local_authority.id,
          address_1: staged_school.address_1,
          address_2: staged_school.address_2,
          address_3: staged_school.address_3,
          town: staged_school.town,
          postcode: staged_school.postcode,
          phase: staged_school.phase,
          establishment_type: staged_school.establishment_type,
        )
      end
    end

    context 'when a school does not already exist' do
      it 'creates a new school record' do
        expect {
          service.update_schools
        }.to change { School.count }.by(1)
      end

      it 'sets the correct values on the School record' do
        service.update_schools

        expect(School.last).to have_attributes(
          urn: staged_school.urn,
          name: staged_school.name,
          responsible_body_id: local_authority.id,
          address_1: staged_school.address_1,
          address_2: staged_school.address_2,
          address_3: staged_school.address_3,
          town: staged_school.town,
          postcode: staged_school.postcode,
          phase: staged_school.phase,
          establishment_type: staged_school.establishment_type,
        )
      end
    end

    context 'when a school already exists' do
      let!(:school) { create(:school, urn: '103001', responsible_body: local_authority) }

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
        )
      end
    end
  end
end

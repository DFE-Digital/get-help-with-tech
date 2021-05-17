require 'rails_helper'

RSpec.describe TrustUpdateService, type: :model do
  describe 'importing trusts from staging' do
    let(:service) { subject }
    let!(:trust) { create(:trust, companies_house_number: '098765432') }

    context 'data update timestamps' do
      it 'updates the DataUpdateRecord timestamp for trusts' do
        t = Time.zone.now
        Timecop.freeze(t) do
          service.update_trusts
          expect(DataStage::DataUpdateRecord.last_update_for(:trusts)).to be_within(1.second).of(t)
        end
      end

      it 'only applies changes since the last update' do
        Timecop.travel(6.hours.ago)
        create(:staged_trust, companies_house_number: '098765432')
        Timecop.return

        Timecop.travel(2.hours.ago)
        DataStage::DataUpdateRecord.updated!(:trusts)
        Timecop.return

        trust_attrs = trust.attributes.symbolize_keys
        service.update_trusts

        expect(trust.reload).to have_attributes(
          companies_house_number: trust_attrs[:companies_house_number],
          name: trust_attrs[:name],
          address_1: trust_attrs[:address_1],
          address_2: trust_attrs[:address_2],
          address_3: trust_attrs[:address_3],
          town: trust_attrs[:town],
          postcode: trust_attrs[:postcode],
          organisation_type: trust_attrs[:organisation_type],
          status: trust_attrs[:status],
        )
      end
    end

    context 'when a trust already exists' do
      let!(:trust) { create(:trust, companies_house_number: '01111222') }
      let!(:staged_trust) { create(:staged_trust, companies_house_number: '01111222') }

      it 'updates the existing trust record' do
        service.update_trusts
        expect(trust.reload).to have_attributes(
          companies_house_number: staged_trust.companies_house_number,
          name: staged_trust.name,
          address_1: staged_trust.address_1,
          address_2: staged_trust.address_2,
          address_3: staged_trust.address_3,
          town: staged_trust.town,
          postcode: staged_trust.postcode,
          organisation_type: staged_trust.organisation_type,
          status: staged_trust.status,
        )
      end
    end

    context 'when a trust exists and goes from open to closed' do
      let!(:trust) { create(:trust, companies_house_number: '01111222') }
      let!(:staged_trust) { create(:staged_trust, :closed, companies_house_number: '01111222') }

      it 'updates the existing trust record' do
        service.update_trusts
        expect(trust.reload).to have_attributes(
          companies_house_number: staged_trust.companies_house_number,
          name: staged_trust.name,
          address_1: staged_trust.address_1,
          address_2: staged_trust.address_2,
          address_3: staged_trust.address_3,
          town: staged_trust.town,
          postcode: staged_trust.postcode,
          organisation_type: staged_trust.organisation_type,
          status: staged_trust.status,
        )
      end
    end
  end
end

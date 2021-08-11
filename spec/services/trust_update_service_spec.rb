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

    context 'when a trust does not exist' do
      let!(:staged_trust) { create(:staged_trust, companies_house_number: '01111222', status: trust_status) }
      let(:new_trust) { Trust.find_by(companies_house_number: '01111222') }

      before do
        service.update_trusts
      end

      context "when it is a closed one" do
        let(:trust_status) { "closed" }

        it "do not create a Trust entry for it" do
          expect(new_trust).to be_nil
        end
      end

      context "when it is not closed" do
        let(:trust_status) { "open" }

        it 'creates an associated trust record' do
          expect(new_trust).to have_attributes(
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

  describe 'closing trusts from staging' do
    let(:service) { subject }

    context 'when a trust is open and needs closing' do
      let!(:trust) { create(:trust, companies_house_number: '01111223') }

      before { create(:staged_trust, :closed, companies_house_number: '01111223') }

      it 'updates the existing trust record' do
        service.update_trusts
        expect(trust.reload).to have_attributes(
          computacenter_change: 'closed',
          status: 'closed',
        )
      end
    end

    context 'trusts that have schools' do
      let!(:trust) { create(:trust) }
      let!(:trust_with_schools_1) { create(:trust, :with_schools) }
      let!(:trust_with_schools_2) { create(:trust, :with_schools) }

      before do
        create(:staged_trust, :closed, companies_house_number: trust.companies_house_number)
        create(:staged_trust, :closed, companies_house_number: trust_with_schools_1.companies_house_number)
        create(:staged_trust, :closed, companies_house_number: trust_with_schools_2.companies_house_number)
      end

      it 'notifies Sentry with a list of skipped trust ids' do
        sentry_scope = double
        allow(sentry_scope).to receive(:set_context)

        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:configure_scope).and_yield(sentry_scope)

        service.update_trusts

        expect(Sentry).to have_received(:capture_message).with(/Skipped auto-closing Trusts as schools.size > 0/)
        expect(sentry_scope).to have_received(:set_context).with(
          'TrustUpdateService#close_trusts',
          { trust_ids: a_collection_containing_exactly(trust_with_schools_1.id, trust_with_schools_2.id) },
        )
      end

      it 'leaves skipped trust as open' do
        service.update_trusts
        expect(trust_with_schools_1.reload).to have_attributes(status: 'open')
        expect(trust_with_schools_2.reload).to have_attributes(status: 'open')
      end

      it 'closes trusts not skipped' do
        service.update_trusts
        expect(trust.reload).to have_attributes(
          computacenter_change: 'closed',
          status: 'closed',
        )
      end
    end
  end
end

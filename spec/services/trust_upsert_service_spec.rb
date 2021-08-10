require 'rails_helper'

RSpec.describe TrustUpsertService, type: :model do
  let(:service) { described_class.new(attrs) }

  describe 'importing trusts' do
    let(:attrs) do
      {
        gias_group_uid: '4001',
        companies_house_number: '09933123',
        name: 'Callio Forsythe Academy',
        address_1: 'Big Academy',
        address_2: 'Strange Lane',
        town: 'Easttown',
        postcode: 'EW1 1AA',
        status: 'closed',
        organisation_type: 'single_academy_trust',
      }
    end

    [DataStage::Trust, Trust].each do |model|
      context "when an associated #{model} does not exist" do
        it 'creates a new record' do
          expect { service.call }.to change { model.count }.by(1)
        end

        it 'sets the correct values on the new record' do
          service.call
          expect(model.last).to have_attributes(attrs)
        end
      end
    end

    %i[staged_trust trust].each do |factory_name|
      context "when an associated #{factory_name} exists already" do
        let!(:existing) { create(factory_name, companies_house_number: '09933123') }
        let(:organisation_type) { existing.organisation_type }
        let(:attrs) do
          {
            gias_group_uid: '4001',
            companies_house_number: '09933123',
            name: 'Academy of Wigtown',
            address_1: 'Academy Campus',
            address_2: 'Wigtown Lane',
            town: 'Wigtown',
            postcode: 'W1G 1AA',
            status: 'open',
            organisation_type: organisation_type,
          }
        end

        before do
          service.call
        end

        it 'updates the existing record' do
          expect(existing.reload).to have_attributes(attrs)
        end
      end
    end
  end
end

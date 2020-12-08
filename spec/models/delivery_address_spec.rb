require 'rails_helper'

RSpec.describe DeliveryAddress do
  describe '#computacenter_identifier' do
    context "when school is an FE institution" do
      let(:school) { create(:fe_school) }

      it 'is generated' do
        expect(school.delivery_address.computacenter_identifier).to eql("#{school.ukprn}-A")
      end

      it 'is sequential when further delivery addresses are added' do
        school.delivery_addresses << (second_delivery_address = DeliveryAddress.new(attributes_for(:delivery_address)))

        expect(second_delivery_address.computacenter_identifier).to eql("#{school.ukprn}-B")
      end
    end

    context "when school is not an FE institution" do
      let(:school) { create(:school) }

      it 'is not generated' do
        expect(school.delivery_address.computacenter_identifier).to be_blank
      end
    end
  end
end

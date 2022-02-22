require 'rails_helper'

RSpec.describe School::DevicesController do
  let(:user) do
    create(:school_user,
           school:,
           orders_devices: true,
           techsource_account_confirmed_at: 1.second.ago)
  end

  before do
    sign_in_as user
  end

  describe '#order' do
    context 'when school state is can_order' do
      context 'when has devices left to order' do
        let(:school) { create(:school, :can_order, laptops: [10, 10]) }

        it 'renders can_order' do
          get :order, params: { urn: school.urn }
          expect(controller).to render_template('school/devices/can_order')
        end
      end

      context 'when does not have devices left to order' do
        let(:school) { create(:school, :can_order) }

        it 'renders cannot_order_as_cap_reached' do
          get :order, params: { urn: school.urn }
          expect(controller).to render_template('school/devices/cannot_order_as_cap_reached')
        end
      end
    end

    context 'when school state is can_order_for_specific_circumstances' do
      let(:school) do
        create(:school,
               order_state: :can_order_for_specific_circumstances,
               std_device_allocation:)
      end

      context 'when has devices left to order' do
        let(:school) { create(:school, :can_order_for_specific_circumstances, laptops: [10, 10]) }

        it 'renders can_order_for_specific_circumstances' do
          get :order, params: { urn: school.urn }
          expect(controller).to render_template('school/devices/can_order_for_specific_circumstances')
        end
      end

      context 'when does not have devices left to order' do
        let(:school) { create(:school, :can_order_for_specific_circumstances) }

        it 'renders cannot_order_as_cap_reached' do
          get :order, params: { urn: school.urn }
          expect(controller).to render_template('school/devices/cannot_order_as_cap_reached')
        end
      end
    end

    context 'when school state cannot order' do
      let(:school) { create(:school, :cannot_order) }

      it 'renders cannot_order' do
        get :order, params: { urn: school.urn }
        expect(controller).to render_template('school/devices/cannot_order')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Support::PerformanceData::SchoolsController, type: :controller do
  describe '#index' do
    context 'when request does not contain a valid authentication token' do
      it 'returns unauthorized error' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when a valid authentication token is supplied' do
      let!(:schools) { create_list(:school, 3, :with_preorder_information, :with_std_device_allocation, :with_coms_device_allocation) }

      before do
        setup_auth_token
        schools[0].std_device_allocation.update!(allocation: 0, cap: 0)
        schools[0].coms_device_allocation.update!(allocation: 0, cap: 0)

        schools[1].std_device_allocation.update!(allocation: 10, cap: 10)
        schools[2].coms_device_allocation.update!(allocation: 10, cap: 0)
      end

      it 'does not return an unauthorized status' do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'lists schools with allocations or caps in JSON format' do
        get :index
        payload = JSON.parse(response.body)

        expect(payload.count).to eq(2)
        expect(payload).to include(school_data(schools[1]))
        expect(payload).to include(school_data(schools[2]))
      end
    end
  end

  def school_data(school)
    {
      'school_name' => school.name,
      'school_urn' => school.urn.to_s,
      'responsible_body_name' => school.responsible_body.name,
      'responsible_body_gias_id' => school.responsible_body.gias_id,
      'responsible_body_companies_house_number' => school.responsible_body.companies_house_number,
      'allocation' => school.std_device_allocation.allocation,
      'cap' => school.std_device_allocation.cap,
      'devices_ordered' => school.std_device_allocation.devices_ordered,
      'coms_allocation' => school.coms_device_allocation.allocation,
      'coms_cap' => school.coms_device_allocation.cap,
      'coms_devices_ordered' => school.coms_device_allocation.devices_ordered,
      'preorder_info_status' => school.preorder_information.status,
      'school_order_state' => school.order_state,
      'who_will_order_devices' => school.who_will_order_devices,
    }
  end

  def setup_auth_token
    token = SecureRandom.hex
    allow(controller).to receive(:access_token).and_return(token)
    request.headers['Authorization'] = "Bearer #{token}"
  end
end

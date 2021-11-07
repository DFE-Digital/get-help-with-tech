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
      let!(:schools) { create_list(:school, 3, :with_preorder_information, laptops: [1, 1, 0], routers: [1, 1, 0]) }

      before do
        stub_computacenter_outgoing_api_calls
        setup_auth_token
        UpdateSchoolDevicesService.new(school: schools[0],
                                       order_state: :can_order_for_specific_circumstances,
                                       laptop_allocation: 0,
                                       circumstances_laptops: -1,
                                       router_allocation: 0,
                                       circumstances_routers: -1).call
        UpdateSchoolDevicesService.new(school: schools[1],
                                       order_state: :can_order_for_specific_circumstances,
                                       laptop_allocation: 10,
                                       router_allocation: 10,
                                       circumstances_routers: -10).call
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
      'responsible_body_name' => school.responsible_body_name,
      'responsible_body_gias_id' => school.responsible_body_gias_id,
      'responsible_body_companies_house_number' => school.responsible_body_companies_house_number,
      'allocation' => school.allocation(:laptop),
      'cap' => school.cap(:laptop),
      'devices_ordered' => school.devices_ordered(:laptop),
      'coms_allocation' => school.allocation(:router),
      'coms_cap' => school.cap(:router),
      'coms_devices_ordered' => school.devices_ordered(:router),
      'preorder_info_status' => school.preorder_status,
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

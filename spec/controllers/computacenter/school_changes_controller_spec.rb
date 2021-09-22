require 'rails_helper'

RSpec.describe Computacenter::SchoolChangesController do
  let(:user) { create(:computacenter_user) }
  let(:school) { create(:school, name: 'SchoolName', computacenter_reference: '11') }

  before do
    sign_in_as user
  end

  describe '#edit' do
    before { get :edit, params: { id: school.urn } }

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'displays the current computacenter reference' do
      expect(assigns[:form].ship_to).to eq('11')
    end
  end

  describe '#update' do
    let(:params) do
      {
        id: school.urn,
        computacenter_ship_to_form: {
          ship_to: '12',
          change_ship_to: 'yes',
        },
      }
    end

    let(:school) do
      create(:school,
             :with_std_device_allocation_partially_ordered,
             :with_coms_device_allocation_partially_ordered,
             name: 'SchoolName',
             computacenter_reference: '11')
    end

    before do
      stub_computacenter_outgoing_api_calls
    end

    it 'redirects' do
      patch :update, params: params

      expect(response).to redirect_to(computacenter_school_changes_path)
    end

    it 'sets the given computacenter reference to the school' do
      patch :update, params: params

      expect(flash[:success]).to eq("Ship To reference for SchoolName is 12")
    end

    it 'update caps on Computacenter' do
      requests = [
        [
          { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '2' },
          { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '2' },
        ]
      ]

      patch :update, params: params

      expect_to_have_sent_caps_to_computacenter(requests)
    end

    it 'do not notify Computacenter by email' do
      expect { patch :update, params: params }
        .not_to have_enqueued_job.on_queue('mailers').with('ComputacenterMailer')
    end

    it 'do not notify the school' do
      expect { patch :update, params: params }
        .not_to have_enqueued_job.on_queue('mailers').with('CanOrderDevicesMailer')
    end
  end
end

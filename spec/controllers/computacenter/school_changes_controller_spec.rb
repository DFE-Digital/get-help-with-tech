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
    let(:change_ship_to) { 'yes' }
    let(:params) do
      {
        id: school.urn,
        computacenter_ship_to_form: {
          ship_to: '12',
          change_ship_to:,
        },
      }
    end

    let(:school) do
      create(:school,
             :in_lockdown,
             laptops: [2, 2, 1],
             routers: [2, 2, 1],
             name: 'SchoolName',
             computacenter_reference: '11')
    end

    before do
      stub_computacenter_outgoing_api_calls
    end

    it 'redirects' do
      patch(:update, params:)

      expect(response).to redirect_to(computacenter_school_changes_path)
    end

    it 'sets the given computacenter reference to the school' do
      patch(:update, params:)

      expect(flash[:success]).to eq('Ship To reference for SchoolName is 12')
    end

    it 'update caps on Computacenter' do
      requests = [
        [
          { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '2' },
          { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '2' },
        ],
      ]

      patch(:update, params:)

      expect_to_have_sent_caps_to_computacenter(requests)
    end

    it 'do not notify Computacenter by email' do
      expect { patch(:update, params:) }
        .not_to have_enqueued_mail(ComputacenterMailer)
    end

    it 'do not notify the school' do
      expect { patch(:update, params:) }
        .not_to have_enqueued_mail(CanOrderDevicesMailer)
    end

    context 'when the computacenter reference cannot be set' do
      let(:change_ship_to) { '--' }

      it 'display the edit view' do
        patch(:update, params:)

        expect(flash[:success]).to be_blank
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

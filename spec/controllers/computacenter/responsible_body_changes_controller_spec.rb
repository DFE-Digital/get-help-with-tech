require 'rails_helper'

RSpec.describe Computacenter::ResponsibleBodyChangesController do
  let(:user) { create(:computacenter_user) }
  let(:rb) do
    create(:local_authority,
           :manages_centrally,
           :vcap_feature_flag,
           name: 'RBName',
           computacenter_reference: '1000')
  end

  before do
    sign_in_as user
    stub_computacenter_outgoing_api_calls
  end

  describe '#edit' do
    before { get :edit, params: { id: rb.id } }

    it 'responds successfully' do
      expect(response).to be_successful
    end

    it 'displays the current computacenter reference' do
      expect(assigns[:form].sold_to).to eq('1000')
    end
  end

  describe '#update' do
    let(:who_manages) { :manages_orders }
    let(:change_sold_to) { 'yes' }

    let(:params) do
      {
        id: rb.id,
        computacenter_sold_to_form: {
          sold_to: '1200',
          change_sold_to: change_sold_to,
        },
      }
    end

    before do
      create(:school,
             who_manages,
             :in_lockdown,
             laptops: [2, 2, 1],
             routers: [2, 2, 1],
             responsible_body: rb,
             computacenter_reference: '11')

      create(:school,
             who_manages,
             :in_lockdown,
             laptops: [2, 2, 1],
             routers: [2, 2, 1],
             responsible_body: rb,
             computacenter_reference: '12')
    end

    it 'redirects' do
      patch :update, params: params

      expect(response).to redirect_to(computacenter_responsible_body_changes_path)
    end

    it 'sets the given computacenter reference to the rb' do
      patch :update, params: params

      expect(flash[:success]).to eq('Sold To reference for RBName is 1200')
    end

    context 'when the rb schools are not in virtual cap pool' do
      let(:who_manages) { :manages_orders }
      let(:requests) do
        [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '2' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '2' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '2' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '2' },
          ],
        ]
      end

      it 'update caps on Computacenter' do
        patch :update, params: params

        expect_to_have_sent_caps_to_computacenter(requests)
      end
    end

    context 'when the rb schools are in virtual cap pool' do
      let(:who_manages) { :centrally_managed }
      let(:requests) do
        [
          [
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '12', 'capAmount' => '3' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '12', 'capAmount' => '3' },
            { 'capType' => 'DfE_RemainThresholdQty|Coms_Device', 'shipTo' => '11', 'capAmount' => '3' },
            { 'capType' => 'DfE_RemainThresholdQty|Std_Device', 'shipTo' => '11', 'capAmount' => '3' },
          ],
        ]
      end

      before { rb.calculate_vcaps! }

      it 'update caps on Computacenter' do
        patch :update, params: params

        expect_to_have_sent_caps_to_computacenter(requests, check_number_of_calls: false)
      end
    end

    it 'do not notify Computacenter by email' do
      expect { patch :update, params: params }
        .not_to have_enqueued_mail(ComputacenterMailer)
    end

    it 'do not notify the school' do
      expect { patch :update, params: params }
        .not_to have_enqueued_mail(CanOrderDevicesMailer)
    end

    context 'when the computacenter reference cannot be set' do
      let(:change_sold_to) { '--' }

      it 'display the edit view' do
        patch :update, params: params

        expect(flash[:success]).to be_blank
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Computacenter::TechsourceController do
  let(:user) { create(:computacenter_user) }

  before do
    sign_in_as user
  end

  describe '#new' do
    it 'loads the page' do
      get :new
      expect(response).to be_successful
    end
  end

  describe '#create' do
    let(:mock_service) { double.as_null_object }

    context 'happy path' do
      it 'calls service' do
        allow(BulkTechsourceService).to receive(:new).with(emails: ['user@example.com']).and_return(mock_service)

        post :create, params: { bulk_techsource_form: { emails: 'user@example.com' } }

        expect(mock_service).to have_received(:call)
      end

      it 'renders the summary' do
        post :create, params: { bulk_techsource_form: { emails: 'user@example.com' } }

        expect(controller).to render_template('computacenter/techsource/summary')
      end
    end

    context 'sad path' do
      it 'does not call service' do
        allow(BulkTechsourceService).to receive(:new).and_return(mock_service)

        post :create, params: { bulk_techsource_form: { emails: '' } }

        expect(mock_service).not_to have_received(:call)
      end

      it 'renders the new template' do
        post :create, params: { bulk_techsource_form: { emails: '' } }

        expect(controller).to render_template('computacenter/techsource/new')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Support::ZendeskStatisticsController, type: :controller do
  let(:support_user) { create(:support_user) }

  describe '#macros' do
    describe 'when ZendeskMacroExportService is successful' do
      before do
        allow(ZendeskMacroExportService).to receive(:new)
                                              .and_return(instance_double(
                                                            'ZendeskMacroExportService',
                                                            csv_generator: 'Col1,Col2,Col3',
                                                            data: 'Col1,Col2,Col3',
                                                            filename: 'test.csv',
                                                            valid?: true,
                                                          ))
        sign_in_as support_user
        get :macros, format: :csv
      end

      it 'returns a csv file' do
        expect(response.header['Content-Type']).to include 'text/csv'
        expect(response.body).to include('Col1,Col2,Col3')
      end
    end

    describe 'when ZendeskMacroExportService fails ' do
      before do
        allow(ZendeskMacroExportService).to receive(:new)
                                              .and_return(instance_double(
                                                            'ZendeskMacroExportService',
                                                            csv_generator: nil,
                                                            message: 'Something failed',
                                                            valid?: false,
                                                          ))
        sign_in_as support_user
        get :macros, format: :csv
      end

      it 'sets flash message' do
        expect(request.flash[:warning]).to eq('Something failed')
      end

      it 'redirects the user back to the page' do
        expect(response).to redirect_to(support_zendesk_statistics_path)
      end
    end
  end
end

require 'rails_helper'

describe Support::AssetSerialUploadsController do
  let(:school_user) { create(:school_user) }
  let(:support_user) { create(:support_user) }
  let(:cc_user) { create(:computacenter_user) }

  describe '#new' do
    specify { expect { get :new }.to be_forbidden_for(school_user) }
    specify { expect { get :new }.to be_forbidden_for(cc_user) }

    context 'logged out' do
      it 'errors' do
        get :new

        expect(response).not_to have_http_status(:ok)
      end
    end

    context 'signed in as support user' do
      before { sign_in_as support_user }

      it 'renders the page' do
        get :new

        expect(response).to render_template(:new)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '#create' do
    let(:csv_file) { fixture_file_upload(file_fixture('serial_numbers.csv')) }

    specify { expect { get :new }.to be_forbidden_for(school_user) }
    specify { expect { get :new }.to be_forbidden_for(cc_user) }

    context 'logged out' do
      it 'errors' do
        post :create, params: { serial_numbers_file: csv_file }

        expect(response).not_to have_http_status(:ok)
      end
    end

    context 'signed in as support user' do
      before { sign_in_as support_user }

      it 'assigns the intersection of serial numbers' do
        a2 = create(:asset, serial_number: 2)
        a3 = create(:asset, serial_number: 3)
        a4 = create(:asset, serial_number: 4)

        post :create, params: { serial_numbers_file: csv_file }

        expect(assigns(:file_contents)).to eq("1\n2\n3\n")
        expect(assigns(:assets)).to contain_exactly(a2, a3)
        expect(assigns(:assets)).not_to include(a4)
        expect(assigns(:missing_serial_numbers)).to contain_exactly('1')
        expect(response).to render_template('create')
      end

      context 'duplicate serial number search' do
        let(:csv_file_with_duplicates) { fixture_file_upload(file_fixture('duplicated_serial_numbers.csv')) }

        it 'removes duplicates' do
          post :create, params: { serial_numbers_file: csv_file_with_duplicates }

          expect(assigns(:file_contents)).to eq("2\n2\n")
          expect(assigns(:missing_serial_numbers)).to contain_exactly('2').and be_one
          expect(response).to render_template('create')
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Support::Gias::SchoolsToCloseController, type: :controller do
  let(:non_support_third_line_user) { create(:user, is_support: true, role: 'no') }
  let(:support_third_line_user) { create(:support_user, :third_line) }

  describe '#index' do
    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify { expect { get :index }.to be_forbidden_for(non_support_third_line_user) }
    end

    context 'support third line users' do
      let!(:staged_school_to_be_closed) { create(:staged_school, :closed) }
      let!(:staged_school_to_be_closed_counterpart) {
        create(:school, urn: staged_school_to_be_closed.urn, status: 'open')
      }
      let!(:staged_school_not_to_be_closed) { create(:staged_school) }

      before do
        sign_in_as support_third_line_user
        get :index
      end

      it 'shows a list of available schools to be closed' do
        expect(response).to be_successful
        expect(assigns(:closed_schools)).to contain_exactly(staged_school_to_be_closed)
      end
    end
  end

  describe 'show' do
    let!(:staged_school_to_be_closed) { create(:staged_school, :closed) }
    let!(:staged_school_to_be_closed_counterpart) {
      create(:school, urn: staged_school_to_be_closed.urn, status: 'open')
    }

    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify {
        expect {
          get :show, params: { urn: staged_school_to_be_closed.urn }
        }.to be_forbidden_for(non_support_third_line_user)
      }
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
        get :show, params: { urn: staged_school_to_be_closed.urn }
      end

      it 'shows the details of the school to be added' do
        expect(response).to be_successful
        expect(assigns(:school)).to eq(staged_school_to_be_closed)
      end
    end
  end

  describe '#update' do
    let!(:staged_school_to_be_closed) { create(:staged_school, :closed) }
    let!(:staged_school_to_be_closed_counterpart) {
      create(:school, urn: staged_school_to_be_closed.urn, status: 'open')
    }

    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify {
        expect {
          patch :update, params: { urn: staged_school_to_be_closed.urn }
        }.to be_forbidden_for(non_support_third_line_user)
      }
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
        patch :update, params: { urn: staged_school_to_be_closed.urn }
      end

      specify { expect(response).to redirect_to(support_gias_schools_to_close_index_path) }
      specify {
        expect(controller)
          .to set_flash[:success]
                .to("#{staged_school_to_be_closed_counterpart.name} (#{staged_school_to_be_closed_counterpart.urn}) has been closed")
      }
      specify { expect(staged_school_to_be_closed_counterpart.reload).to be_gias_status_closed }
    end
  end
end

require 'rails_helper'

RSpec.describe Support::Gias::SchoolsToAddController, type: :controller do
  let(:non_support_third_line_user) { create(:user, is_support: true, role: 'no') }
  let(:support_third_line_user) { create(:support_user, :third_line) }

  describe '#index' do
    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify { expect { get :index }.to be_forbidden_for(non_support_third_line_user) }
    end

    context 'support third line users' do
      let!(:staged_school_to_be_added) { create(:staged_school) }
      let!(:staged_school_not_to_be_added) { create(:staged_school) }
      let!(:school_added_already) { create(:school, urn: staged_school_not_to_be_added.urn) }

      before do
        sign_in_as support_third_line_user
        get :index
      end

      it 'shows a list of available schools to be added' do
        expect(response).to be_successful
        expect(assigns(:new_schools)).to contain_exactly(staged_school_to_be_added)
      end
    end
  end

  describe 'show' do
    let(:staged_school_to_be_added) { create(:staged_school) }

    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify {
        expect {
          get :show, params: { urn: staged_school_to_be_added.urn }
        }.to be_forbidden_for(non_support_third_line_user)
      }
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
        get :show, params: { urn: staged_school_to_be_added.urn }
      end

      it 'shows the details of the school to be added' do
        expect(response).to be_successful
        expect(assigns(:school)).to eq(staged_school_to_be_added)
      end
    end
  end

  describe '#update' do
    let!(:staged_school_to_be_added) { create(:staged_school, responsible_body_name: 'Dorset') }

    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify {
        expect {
          patch :update, params: { urn: staged_school_to_be_added.urn }
        }.to be_forbidden_for(non_support_third_line_user)
      }
    end

    context 'support third line users' do
      let(:new_school) { School.where(urn: staged_school_to_be_added.urn) }

      before do
        sign_in_as support_third_line_user
      end

      context 'when the school can be created' do
        before do
          create(:local_authority, name: 'Dorset Council')
          patch :update, params: { urn: staged_school_to_be_added.urn }
        end

        specify { expect(response).to redirect_to(support_gias_schools_to_add_index_path) }
        specify {
          expect(controller)
            .to set_flash[:success].to("#{staged_school_to_be_added.name} (#{staged_school_to_be_added.urn}) added")
        }
        specify { expect(new_school).to exist }
      end

      context 'when the school cannot be created' do
        before do
          patch :update, params: { urn: staged_school_to_be_added.urn }
        end

        specify { expect(response).to be_successful }
        specify { expect(new_school).not_to exist }

        it 'redisplays the school to be added with errors' do
          expect(response).to be_successful
          expect(assigns(:school)).to eq(staged_school_to_be_added)
          expect(assigns(:school).errors).not_to be_empty
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe Support::Schools::ResponsibleBodyController, type: :controller do
  let(:non_support_third_line_user) { create(:user, is_support: true, role: 'no') }
  let(:support_third_line_user) { create(:support_user, :third_line) }
  let!(:school) { create(:school) }

  describe '#edit' do
    context 'non support third line users' do
      before { sign_in_as non_support_third_line_user }

      specify do
        expect { get :edit, params: { school_urn: school.urn } }.to be_forbidden_for(non_support_third_line_user)
      end
    end

    context 'support third line users' do
      before do
        sign_in_as support_third_line_user
        get :edit, params: { school_urn: school.urn }
      end

      specify { expect(response).to be_successful }

      it 'exposes a form to change the responsible body of the school' do
        expect(assigns(:form)).to be_a(Support::School::ChangeResponsibleBodyForm)
        expect(assigns(:form).school).to eq(school)
      end
    end
  end

  describe '#update' do
    let(:params) do
      {
        school_urn: school.urn,
        support_school_change_responsible_body_form: {
          responsible_body_id: responsible_body_id,
        },
      }
    end

    before { stub_computacenter_outgoing_api_calls }

    context 'non support third line users' do
      let(:responsible_body_id) { school.responsible_body_id.next }

      before { sign_in_as non_support_third_line_user }

      specify do
        expect { patch :update, params: params }.to be_forbidden_for(non_support_third_line_user)
      end
    end

    context 'support third line users' do
      context 'same responsible body' do
        let(:responsible_body_id) { school.responsible_body_id }

        before do
          sign_in_as support_third_line_user
          patch :update, params: params
        end

        it 'redirects back to school' do
          expect(response).to redirect_to(support_school_path(school))
        end

        it 'inform the user about the school responsible body not changed' do
          expect(flash[:info]).to eq("Responsible body not changed for #{school.name}")
        end
      end

      context 'when the responsible body cannot be changed for some reason' do
        let(:new_responsible_body) { create(:trust) }
        let(:responsible_body_id) { new_responsible_body.id }

        before do
          sign_in_as support_third_line_user
          allow(Support::School::ChangeResponsibleBodyForm).to receive(:new).and_return(
            instance_double('Support::School::ChangeResponsibleBodyForm', save: false),
          )
          patch :update, params: params
        end

        it 'redirects back to school' do
          expect(response).to redirect_to(support_school_path(school))
        end

        it 'warns the user about the school responsible body not changed' do
          expect(flash[:warning]).to include("#{school.name} could not be associated with")
        end
      end

      context 'when the responsible body can be changed' do
        let(:new_responsible_body) { create(:trust) }
        let(:responsible_body_id) { new_responsible_body.id }

        before do
          school.refresh_preorder_status!
          sign_in_as support_third_line_user
          patch :update, params: params
        end

        it 'redirects back to school' do
          expect(response).to redirect_to(support_school_path(school))
        end

        it 'shows a successful change message to the user' do
          expect(flash[:success]).to eq("#{school.name} is now associated with #{new_responsible_body.name}")
        end
      end
    end
  end
end

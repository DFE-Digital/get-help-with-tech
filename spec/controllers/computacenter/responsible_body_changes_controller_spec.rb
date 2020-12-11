require 'rails_helper'

RSpec.describe Computacenter::ResponsibleBodyChangesController do
  let(:user) { create(:computacenter_user) }

  before do
    sign_in_as user
  end

  describe '#edit' do
    let(:dfe) { ImportResponsibleBodiesService.new.import_dfe }

    it 'loads the page when the responsible body is the Department for Education' do
      get :edit, params: { id: dfe.id }
      expect(response).to be_successful
    end
  end
end

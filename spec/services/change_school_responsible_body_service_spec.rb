require 'rails_helper'

RSpec.describe ChangeSchoolResponsibleBodyService, type: :model do
  let(:service) { described_class.new(school, new_responsible_body_id) }
  let(:new_responsible_body_id) { create(:local_authority).id }

  describe '#call' do
    context 'when the school cannot be updated for some reason' do
      let(:school) { create(:school, :with_preorder_information) }

      it 'do not change the school responsible body' do
        expect {
          school.name = nil
          service.call
        }.not_to(change { school.reload.responsible_body_id })
      end

      it 'do not change the school preorder information' do
        expect {
          school.name = nil
          service.call
        }.not_to(change { school.reload.preorder_information })
      end
    end

    context 'when the school preorder information cannot be refreshed for some reason' do
      let(:school) { create(:school) }

      it 'do not change the school responsible body' do
        expect {
          service.call
        }.not_to(change { school.reload.responsible_body_id })
      end

      it 'do not change the school preorder information' do
        expect {
          service.call
        }.not_to(change { school.reload.preorder_information })
      end
    end

    context 'success' do
      let(:school) { create(:school, :with_preorder_information) }

      it 'update the school responsible body' do
        expect {
          service.call
        }.to(change { school.reload.responsible_body_id })
      end

      it 'refresh the school preorder information' do
        preorder_information = instance_spy(PreorderInformation, refresh_status!: true)
        allow(school).to receive(:preorder_information).and_return(preorder_information)

        service.call

        expect(preorder_information).to have_received(:refresh_status!)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ChangeSchoolResponsibleBodyService, type: :model do
  let(:service) { described_class.new(moving_school, new_rb) }
  let(:new_rb) { create(:local_authority, :manages_centrally, :vcap_feature_flag) }

  describe '#call' do
    context 'when the school cannot be updated for some reason' do
      let(:moving_school) { create(:school, :with_preorder_information) }

      it 'do not change the school responsible body' do
        expect {
          moving_school.name = nil
          service.call
        }.not_to(change { moving_school.reload.responsible_body_id })
      end

      it 'do not change the school preorder information' do
        expect {
          moving_school.name = nil
          service.call
        }.not_to(change { moving_school.reload.preorder_information })
      end
    end

    context 'when the school preorder information cannot be refreshed for some reason' do
      let(:moving_school) { create(:school) }

      it 'do not change the school responsible body' do
        expect {
          service.call
        }.not_to(change { moving_school.reload.responsible_body_id })
      end

      it 'do not change the school preorder information' do
        expect {
          service.call
        }.not_to(change { moving_school.reload.preorder_information })
      end
    end

    context 'success' do
      let(:moving_school) { create(:school, :with_preorder_information) }
      let(:initial_rb) { moving_school.responsible_body }

      before do
        stub_computacenter_outgoing_api_calls
      end

      it 'update the school responsible body' do
        expect {
          service.call
        }.to(change { moving_school.reload.responsible_body_id }.from(initial_rb.id).to(new_rb.id))
      end

      it 'refresh the school preorder information' do
        preorder_information = instance_spy(PreorderInformation, refresh_status!: true)
        allow(moving_school).to receive(:preorder_information).and_return(preorder_information)

        service.call

        expect(preorder_information).to have_received(:refresh_status!)
      end

      context 'when the school is centrally managed' do
        let!(:initial_rb) { create(:trust, :manages_centrally, :vcap_feature_flag) }
        let!(:school_a) { create_and_put_school_in_pool(initial_rb) }
        let!(:moving_school) { create_and_put_school_in_pool(initial_rb) }
        let!(:school_b) { create_and_put_school_in_pool(new_rb) }

        let(:initial_rb_std_device_start_allocation) { [school_a, moving_school].map(&:std_device_allocation).sum(&:raw_allocation) }
        let(:initial_rb_std_device_end_allocation) { school_a.std_device_allocation.raw_allocation }
        let(:new_rb_std_device_start_allocation) { school_b.std_device_allocation.raw_allocation }
        let(:new_rb_std_device_end_allocation) { [school_b, moving_school].map(&:std_device_allocation).sum(&:raw_allocation) }
        let(:initial_rb_std_device_start_cap) { [school_a, moving_school].map(&:std_device_allocation).sum(&:raw_cap) }
        let(:initial_rb_std_device_end_cap) { school_a.std_device_allocation.raw_cap }
        let(:new_rb_std_device_start_cap) { school_b.std_device_allocation.raw_cap }
        let(:new_rb_std_device_end_cap) { [school_b, moving_school].map(&:std_device_allocation).sum(&:raw_cap) }
        let(:initial_rb_std_device_start_devices_ordered) { [school_a, moving_school].map(&:std_device_allocation).sum(&:raw_devices_ordered) }
        let(:initial_rb_std_device_end_devices_ordered) { school_a.std_device_allocation.raw_devices_ordered }
        let(:new_rb_std_device_start_devices_ordered) { school_b.std_device_allocation.raw_devices_ordered }
        let(:new_rb_std_device_end_devices_ordered) { [school_b, moving_school].map(&:std_device_allocation).sum(&:raw_devices_ordered) }

        let(:initial_rb_coms_device_start_allocation) { [school_a, moving_school].map(&:coms_device_allocation).sum(&:raw_allocation) }
        let(:initial_rb_coms_device_end_allocation) { school_a.coms_device_allocation.raw_allocation }
        let(:new_rb_coms_device_start_allocation) { school_b.coms_device_allocation.raw_allocation }
        let(:new_rb_coms_device_end_allocation) { [school_b, moving_school].map(&:coms_device_allocation).sum(&:raw_allocation) }
        let(:initial_rb_coms_device_start_cap) { [school_a, moving_school].map(&:coms_device_allocation).sum(&:raw_cap) }
        let(:initial_rb_coms_device_end_cap) { school_a.coms_device_allocation.raw_cap }
        let(:new_rb_coms_device_start_cap) { school_b.coms_device_allocation.raw_cap }
        let(:new_rb_coms_device_end_cap) { [school_b, moving_school].map(&:coms_device_allocation).sum(&:raw_cap) }
        let(:initial_rb_coms_device_start_devices_ordered) { [school_a, moving_school].map(&:coms_device_allocation).sum(&:raw_devices_ordered) }
        let(:initial_rb_coms_device_end_devices_ordered) { school_a.coms_device_allocation.raw_devices_ordered }
        let(:new_rb_coms_device_start_devices_ordered) { school_b.coms_device_allocation.raw_devices_ordered }
        let(:new_rb_coms_device_end_devices_ordered) { [school_b, moving_school].map(&:coms_device_allocation).sum(&:raw_devices_ordered) }

        it 'remove school std allocation from the initial responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.std_device.first.allocation }
                  .from(initial_rb_std_device_start_allocation)
                  .to(initial_rb_std_device_end_allocation)
        end

        it 'remove school std device caps from the initial responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.std_device.first.cap }
                  .from(initial_rb_std_device_start_cap)
                  .to(initial_rb_std_device_end_cap)
        end

        it 'remove school std devices_ordered from the initial responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.std_device.first.devices_ordered }
                  .from(initial_rb_std_device_start_devices_ordered)
                  .to(initial_rb_std_device_end_devices_ordered)
        end

        it 'add school std allocation to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.std_device.first.allocation }
                  .from(new_rb_std_device_start_allocation)
                  .to(new_rb_std_device_end_allocation)
        end

        it 'add school std device cap to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.std_device.first.cap }
                  .from(new_rb_std_device_start_cap)
                  .to(new_rb_std_device_end_cap)
        end

        it 'add school std devices_ordered to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.std_device.first.devices_ordered }
                  .from(new_rb_std_device_start_devices_ordered)
                  .to(new_rb_std_device_end_devices_ordered)
        end

        it 'remove school coms allocation to the new responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.coms_device.first.allocation }
                  .from(initial_rb_coms_device_start_allocation)
                  .to(initial_rb_coms_device_end_allocation)
        end

        it 'remove school coms device cap from the initial responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.coms_device.first.cap }
                  .from(initial_rb_coms_device_start_cap)
                  .to(initial_rb_coms_device_end_cap)
        end

        it 'remove school coms devices_ordered from the initial responsible body' do
          expect { service.call }
            .to change { initial_rb.virtual_cap_pools.coms_device.first.devices_ordered }
                  .from(initial_rb_coms_device_start_devices_ordered)
                  .to(initial_rb_coms_device_end_devices_ordered)
        end

        it 'add school com allocation to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.coms_device.first.allocation }
                  .from(new_rb_coms_device_start_allocation)
                  .to(new_rb_coms_device_end_allocation)
        end

        it 'add school com device cap to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.coms_device.first.cap }
                  .from(new_rb_coms_device_start_cap)
                  .to(new_rb_coms_device_end_cap)
        end

        it 'add school com devices_ordered to the new responsible body' do
          expect { service.call }
            .to change { new_rb.virtual_cap_pools.coms_device.first.devices_ordered }
                  .from(new_rb_coms_device_start_devices_ordered)
                  .to(new_rb_coms_device_end_devices_ordered)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ViewHelper do
  let(:school) { School.new(device_allocations: allocations) }

  describe '#what_to_order_allocation_list' do
    context 'with school device allocations' do
      context 'when devices available to order' do
        let(:allocations) { [SchoolDeviceAllocation.new(cap: 4, devices_ordered: 1)] }

        it 'returns X devices' do
          expect(helper.what_to_order_allocation_list(allocations: allocations)).to eql('3 devices')
        end
      end

      context 'when devices and routers available to order' do
        let(:allocation1) { SchoolDeviceAllocation.new(device_type: :std_device, cap: 10, devices_ordered: 3) }
        let(:allocation2) { SchoolDeviceAllocation.new(device_type: :coms_device, cap: 4, devices_ordered: 1) }
        let(:allocations) { [allocation1, allocation2] }

        it 'X devices and X routers' do
          expect(helper.what_to_order_allocation_list(allocations: allocations)).to eql('7 devices and 3 routers')
        end
      end
    end

    context 'with virtual cap pool allocations' do
      context 'when devices available to order' do
        let(:allocations) { [VirtualCapPool.new(cap: 4, devices_ordered: 1)] }

        it 'returns X devices' do
          expect(helper.what_to_order_allocation_list(allocations: allocations)).to eql('3 devices')
        end
      end

      context 'when devices and routers available to order' do
        let(:allocation1) { VirtualCapPool.new(device_type: :std_device, cap: 10, devices_ordered: 3) }
        let(:allocation2) { VirtualCapPool.new(device_type: :coms_device, cap: 4, devices_ordered: 1) }
        let(:allocations) { [allocation1, allocation2] }

        it 'X devices and X routers' do
          expect(helper.what_to_order_allocation_list(allocations: allocations)).to eql('7 devices and 3 routers')
        end
      end
    end
  end

  describe '#what_to_order_availability' do
    context 'when devices available to order' do
      let(:allocations) { [SchoolDeviceAllocation.new(cap: 4, devices_ordered: 1)] }

      it 'returns Order X devices' do
        expect(helper.what_to_order_availability(school: school)).to eql('Order 3 devices')
      end

      context 'when ordering for specific circumstances' do
        let(:school) { School.new(device_allocations: allocations, order_state: :can_order_for_specific_circumstances) }

        it 'returns Order X devices for specific circumstances' do
          expect(helper.what_to_order_availability(school: school)).to eql('Order 3 devices for specific circumstances')
        end
      end
    end

    context 'when devices and routers available to order' do
      let(:allocation1) { SchoolDeviceAllocation.new(device_type: :std_device, cap: 10, devices_ordered: 3) }
      let(:allocation2) { SchoolDeviceAllocation.new(device_type: :coms_device, cap: 4, devices_ordered: 1) }
      let(:allocations) { [allocation1, allocation2] }

      it 'returns Order X devices and X routers' do
        expect(helper.what_to_order_availability(school: school)).to eql('Order 7 devices and 3 routers')
      end
    end

    context 'when no devices available to order' do
      let(:allocations) { [SchoolDeviceAllocation.new(cap: 1, devices_ordered: 1)] }

      it 'returns All devices ordered' do
        expect(helper.what_to_order_availability(school: school)).to eql('All devices ordered')
      end
    end
  end

  describe '#what_to_order_state_list' do
    context 'when devices available to order' do
      let(:allocations) { [SchoolDeviceAllocation.new(cap: 4, devices_ordered: 2)] }

      it 'returns X devices' do
        expect(helper.what_to_order_state_list(allocations: allocations)).to eql('2 devices')
      end
    end

    context 'when devices and routers available to order' do
      let(:allocation1) { SchoolDeviceAllocation.new(device_type: :std_device, cap: 10, devices_ordered: 3) }
      let(:allocation2) { SchoolDeviceAllocation.new(device_type: :coms_device, cap: 4, devices_ordered: 2) }
      let(:allocations) { [allocation1, allocation2] }

      it 'returns X devices and X routers' do
        expect(helper.what_to_order_state_list(allocations: allocations)).to eql('3 devices and 2 routers')
      end
    end
  end

  describe '#what_to_order_state' do
    context 'when devices available to order' do
      let(:allocations) { [SchoolDeviceAllocation.new(cap: 4, devices_ordered: 2)] }

      it 'returns You\'ve ordered X devices' do
        expect(helper.what_to_order_state(school: school)).to eql('You’ve ordered 2 devices')
      end
    end

    context 'when devices and routers available to order' do
      let(:allocation1) { SchoolDeviceAllocation.new(device_type: :std_device, cap: 10, devices_ordered: 3) }
      let(:allocation2) { SchoolDeviceAllocation.new(device_type: :coms_device, cap: 4, devices_ordered: 2) }
      let(:allocations) { [allocation1, allocation2] }

      it 'returns Order X devices and X routers' do
        expect(helper.what_to_order_state(school: school)).to eql('You’ve ordered 3 devices and 2 routers')
      end
    end
  end

  describe '#chromebook_domain_label' do
    let(:school) { build(:school, :la_maintained) }
    let(:result) { helper.chromebook_domain_label(school) }

    it 'starts with the capitalized institution_type' do
      expect(result).to start_with('School')
    end

    it 'ends with email domain registered for <span class="app-no-wrap">G Suite for Education</span>' do
      expect(result).to end_with('email domain registered for <span class="app-no-wrap">G Suite for Education</span>')
    end

    context 'when the school is not a FurtherEducationSchool' do
      context 'and the responsible body is a local authority' do
        it 'starts with School or local authority' do
          expect(result).to start_with('School or local authority')
        end
      end

      context 'and the responsible body is a trust' do
        let(:school) { build(:school, :academy) }

        it 'starts with School or local authority' do
          expect(result).to start_with('School or trust')
        end
      end
    end

    context 'when the school is a FurtherEducationSchool' do
      let(:school) { build(:fe_school, fe_type: 'sixth_form_college') }

      it 'starts with College' do
        expect(result).to start_with('College')
      end

      it 'does not include " or "' do
        expect(result).not_to include(' or ')
      end
    end
  end

  describe '#link_to_urn_otherwise_urn' do
    context 'when school exists' do
      before do
        create(:school, urn: 123_456)
      end

      it 'renders link to school' do
        output = helper.link_to_urn_otherwise_urn(123_456)
        doc = Nokogiri::HTML(output)

        expect(doc.css('a').attribute('href').value).to eql('/support/schools/123456')
        expect(doc.css('a').text).to eql('123456')
      end
    end

    context 'when school does not exist' do
      it 'renders text' do
        expect(helper.link_to_urn_otherwise_urn(123_456)).to be(123_456)
      end
    end
  end
end

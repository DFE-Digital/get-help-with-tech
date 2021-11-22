require 'rails_helper'

RSpec.describe ViewHelper do
  describe '#what_to_order_allocation_list' do
    context 'with school device allocations' do
      context 'when devices available to order' do
        let(:school) { build_stubbed(:school, :in_lockdown, laptops: [4, 4, 1]) }

        it 'returns X devices' do
          expect(helper.what_to_order_allocation_list(school)).to eql('3 devices and 0 routers')
        end
      end

      context 'when devices and routers available to order' do
        let(:school) { build_stubbed(:school, :in_lockdown, laptops: [10, 10, 3], routers: [4, 4, 1]) }

        it 'X devices and X routers' do
          expect(helper.what_to_order_allocation_list(school)).to eql('7 devices and 3 routers')
        end
      end
    end

    context 'with virtual cap pool allocations' do
      context 'when devices available to order' do
        let(:rb) { build_stubbed(:responsible_body, laptops: [4, 4, 1]) }

        it 'returns X devices' do
          expect(helper.what_to_order_allocation_list(rb)).to eql('3 devices and 0 routers')
        end
      end

      context 'when devices and routers available to order' do
        let(:rb) { build_stubbed(:responsible_body, laptops: [10, 10, 3], routers: [4, 4, 1]) }

        it 'X devices and X routers' do
          expect(helper.what_to_order_allocation_list(rb)).to eql('7 devices and 3 routers')
        end
      end
    end
  end

  describe '#what_to_order_availability' do
    context 'when devices available to order' do
      let(:school) { create(:school, :in_lockdown, laptops: [10, 4, 1]) }

      it 'returns Order X devices' do
        expect(helper.what_to_order_availability(school)).to eql('Order 3 devices and 0 routers')
      end

      context 'when ordering for specific circumstances' do
        let(:school) do
          build_stubbed(:school, :can_order_for_specific_circumstances, laptops: [10, 4, 1])
        end

        it 'returns Order X devices for specific circumstances' do
          expect(helper.what_to_order_availability(school)).to eql('Order 3 devices and 0 routers for specific circumstances')
        end
      end
    end

    context 'when devices and routers available to order' do
      let(:school) { build_stubbed(:school, :in_lockdown, laptops: [20, 10, 3], routers: [20, 4, 1]) }

      it 'returns Order X devices and X routers' do
        expect(helper.what_to_order_availability(school)).to eql('Order 7 devices and 3 routers')
      end
    end

    context 'when no devices available to order' do
      let(:school) { build_stubbed(:school, laptops: [1, 1, 1]) }

      it 'returns All devices ordered' do
        expect(helper.what_to_order_availability(school)).to eql('All devices ordered')
      end
    end
  end

  describe '#what_to_order_state_list' do
    context 'when devices available to order' do
      let(:school) { build_stubbed(:school, laptops: [20, 4, 2]) }

      it 'returns X devices' do
        expect(helper.what_to_order_state_list(school)).to eql('2 devices and 0 routers')
      end
    end

    context 'when devices and routers available to order' do
      let(:school) { build_stubbed(:school, laptops: [20, 10, 3], routers: [20, 4, 2]) }

      it 'returns X devices and X routers' do
        expect(helper.what_to_order_state_list(school)).to eql('3 devices and 2 routers')
      end
    end
  end

  describe '#what_to_order_state' do
    context 'when devices available to order' do
      let(:school) { build_stubbed(:school, laptops: [20, 12, 2]) }

      it 'returns You\'ve ordered X devices' do
        expect(helper.what_to_order_state(school)).to eql('You’ve ordered 2 devices and 0 routers')
      end
    end

    context 'when devices and routers available to order' do
      let(:school) { build_stubbed(:school, laptops: [20, 10, 3], routers: [20, 4, 2]) }

      it 'returns Order X devices and X routers' do
        expect(helper.what_to_order_state(school)).to eql('You’ve ordered 3 devices and 2 routers')
      end
    end
  end

  describe '#chromebook_domain_label' do
    let(:school) { build(:school, :la_maintained) }
    let(:result) { helper.chromebook_domain_label(school) }

    specify { expect(result).to eq('School or local authority email domain registered for <span class="app-no-wrap">G Suite for Education</span> (for example, &lsquo;school.co.uk&rsquo;)') }

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

  describe '#link_to_urn_or_ukprn_otherwise_identifier' do
    context 'when school exists' do
      before do
        create(:school, urn: 123_456)
      end

      it 'renders link to school' do
        output = helper.link_to_urn_or_ukprn_otherwise_identifier(123_456)
        doc = Nokogiri::HTML(output)

        expect(doc.css('a').attribute('href').value).to eql('/support/schools/123456')
        expect(doc.css('a').text).to eql('123456')
      end
    end

    context 'when school does not exist' do
      it 'renders text' do
        expect(helper.link_to_urn_or_ukprn_otherwise_identifier(123_456)).to be(123_456)
      end
    end
  end

  describe '#asset_bios_password_or_unlocker' do
    let(:result) { helper.asset_bios_password_or_unlocker(asset) }

    context 'when the device is bios unlockable' do
      let(:asset) { create(:asset, :unlockable) }
      let(:unlocker_link) { "<a class=\"govuk-link\" href=\"/assets/#{asset.to_param}/bios_unlocker\">Download BIOS unlocker</a>" }

      it 'return a link to download the unlocker' do
        expect(result).to eq(unlocker_link)
      end
    end

    context 'when the device is not bios unlockable' do
      let(:asset) { create(:asset) }

      it 'return the asset bios plain password' do
        expect(result).to eq(asset.bios_password)
      end
    end
  end
end

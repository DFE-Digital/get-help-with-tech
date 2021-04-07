require 'rails_helper'

RSpec.describe Computacenter::TechSourceMaintenanceBannerComponent, type: :component do
  alias_method :component, :page

  describe '#message' do
    context 'within window' do
      before do
        stub_const('Computacenter::TechSourceMaintenanceBannerComponent::MAINTENANCE_WINDOW',
                   Time.zone.parse('4 Jan 2021 09:00')..Time.zone.parse('4 Jan 2021 22:00'))
        Timecop.travel(Time.zone.parse('4 Jan 2021 15:00'))
      end

      specify { expect(described_class.new.message).to eq('The TechSource website will be closed for maintenance on Monday 4 January 09:00am. You can order devices when it reopens on Monday 4 January 10:00pm.') }
    end
  end

  describe '#render?' do
    before do
      stub_const('Computacenter::TechSourceMaintenanceBannerComponent::MAINTENANCE_WINDOW',
                 Time.zone.parse('4 Jan 2021 09:00')..Time.zone.parse('4 Jan 2021 10:00'))
    end

    context 'one minute before midnight two days before' do
      before do
        Timecop.travel(Time.zone.parse('1 Jan 2021 23:59'))
        render_inline(described_class.new)
      end

      specify { expect(component.text).not_to be_present }
    end

    context 'one minute after midnight two days before' do
      before do
        Timecop.travel(Time.zone.parse('2 Jan 2021 00:01'))
        render_inline(described_class.new)
      end

      specify { expect(component.text).to be_present }
    end

    context 'one minute before end of maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('4 Jan 2021 09:59'))
        render_inline(described_class.new)
      end

      specify { expect(component.text).to be_present }
    end

    context 'one minute after maintenance window' do
      before do
        Timecop.travel(Time.zone.parse('4 Jan 2021 10:01'))
        render_inline(described_class.new)
      end

      specify { expect(component.text).not_to be_present }
    end
  end
end

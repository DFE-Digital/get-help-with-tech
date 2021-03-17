require 'rails_helper'

RSpec.describe ReportableEvent do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of(:event_name) }

  describe 'being created' do
    context 'when there is no event_time' do
      it 'defaults event_time to now' do
        event = ReportableEvent.create!(event_name: 'Testing')
        expect(event.event_time).to be_within(1.second).of(Time.zone.now.utc)
      end
    end
  end
end

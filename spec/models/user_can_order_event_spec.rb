require 'rails_helper'

RSpec.describe UserCanOrderEvent do
  let(:school) { build(:school) }

  subject(:event) do
    described_class.new(type: 'nudge_user_to_read_privacy_policy',
                        school:)
  end

  describe '#message' do
    it 'returns meaningful message' do
      expect(event.message).to eql("We emailed a user asking them to sign in and read the privacy policy so that #{school.name} can place orders")
    end
  end
end

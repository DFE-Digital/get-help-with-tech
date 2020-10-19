require 'rails_helper'

RSpec.describe UserCanOrderEvent do
  let(:school) { build(:school) }

  subject(:event) do
    described_class.new(type: 'nudge_user_to_read_privacy_policy',
                        school: school)
  end

  describe '#message' do
    it 'returns meaningful message' do
      expect(event.message).to eql("A user from #{school.name} was nudged to read the privacy policy")
    end
  end
end

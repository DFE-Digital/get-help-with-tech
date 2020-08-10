require 'rails_helper'

RSpec.describe SendSlackMessageJob do
  describe '#perform' do
    let(:mock_msg) { instance_double(SlackMessage) }
    let(:given_args) { { arg1: 'arg1 value' } }

    before do
      allow(SlackMessage).to receive(:new).and_return(mock_msg)
      allow(mock_msg).to receive(:send_now!)
    end

    it 'sends a new SlackMessage with the given arguments' do
      SendSlackMessageJob.new.perform(given_args)
      expect(SlackMessage).to have_received(:new).with(given_args)
      expect(mock_msg).to have_received(:send_now!)
    end
  end
end

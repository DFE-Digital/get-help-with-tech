require 'rails_helper'

RSpec.describe SlackMessage do
  let(:msg) { SlackMessage.new }

  describe '#send_now!' do
    let(:test_payload) do
      { this_is: 'my test payload' }
    end
    let(:json_payload) { test_payload.to_json }
    let(:mock_response) do
      instance_double('HTTP::Response', status: instance_double('HTTP::Response::Status', success?: success), body: 'mock response body')
    end
    let(:success) { true }

    before do
      msg.webhook_url = 'http://test.example.com/'
      allow(msg).to receive(:payload).and_return(test_payload)
      allow(HTTP).to receive(:post).and_return(mock_response)
    end

    it 'posts the payload to the webhook_url' do
      msg.send_now!
      expect(HTTP).to have_received(:post).with('http://test.example.com/', body: json_payload)
    end

    context 'when the post is a success' do
      let(:success) { true }

      it 'does not raise an error' do
        expect { msg.send_now! }.not_to raise_error
      end
    end

    context 'when the post is not a success' do
      let(:success) { false }

      it 'raises a SlackMessageError' do
        expect { msg.send_now! }.to raise_error(SlackMessage::SlackMessageError)
      end
    end
  end

  describe 'send_later' do
    before do
      msg.channel = 'my-channel'
      msg.text = 'my text'
      msg.username = 'username'
      msg.webhook_url = 'test url'

      allow(SendSlackMessageJob).to receive(:perform_later)
    end

    it 'calls SendSlackMessageJob.perform_later with the payload as an argument' do
      msg.send_later
      expect(SendSlackMessageJob).to have_received(:perform_later).with(msg.payload)
    end
  end
end

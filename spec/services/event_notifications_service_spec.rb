require 'rails_helper'

RSpec.describe EventNotificationsService do
  let(:notifiable) { true }
  let(:event) do
    instance_double(Event, notifiable?: notifiable, message: 'test message')
  end

  describe '.broadcast' do
    before do
      allow(EventNotificationsService).to receive(:log)
      allow(EventNotificationsService).to receive(:send_slack_notification)
    end

    it 'logs the event' do
      EventNotificationsService.broadcast(event)
      expect(EventNotificationsService).to have_received(:log).with(event)
    end

    context 'when the event is notifiable' do
      it 'sends a slack notification' do
        EventNotificationsService.broadcast(event)
        expect(EventNotificationsService).to have_received(:send_slack_notification).with(event)
      end
    end

    context 'when the event is not notifiable' do
      let(:notifiable) { false }

      it 'does not send a slack notification' do
        EventNotificationsService.broadcast(event)
        expect(EventNotificationsService).not_to have_received(:send_slack_notification).with(event)
      end
    end
  end

  describe '.format_message' do
    let(:msg) { EventNotificationsService.send(:format_message, event) }

    it 'adds a prefix of the class name in square brackets' do
      expect(msg).to start_with('[Instance verifying double]')
    end

    it 'contains the given events message' do
      expect(msg).to include(event.message)
    end
  end

  describe 'log' do
    let(:mock_logger) { instance_double(Rails.logger.class) }

    before do
      allow(mock_logger).to receive(:info)
      allow(EventNotificationsService).to receive(:logger).and_return(mock_logger)
    end

    it 'info-logs a message' do
      EventNotificationsService.send(:log, event)
      expect(mock_logger).to have_received(:info)
    end

    it 'starts the log message with EventNotification:' do
      EventNotificationsService.send(:log, event)
      expect(mock_logger).to have_received(:info) do |msg|
        expect(msg).to start_with('EventNotification:')
      end
    end

    it 'includes event class name in the log message' do
      EventNotificationsService.send(:log, event)
      expect(mock_logger).to have_received(:info) do |msg|
        expect(msg).to include(event.class.name)
      end
    end

    it 'contains the given events message' do
      EventNotificationsService.send(:log, event)
      expect(mock_logger).to have_received(:info) do |msg|
        expect(msg).to include(event.message)
      end
    end
  end
end

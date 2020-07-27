module NotifyHelper
  def mock_notify_sms_client
    sms_client = instance_double('Notifications::Client')
    allow_any_instance_of(NotifyExtraMobileDataAccountHolderService).to receive(:sms_client).and_return(sms_client)
    sms_client
  end

  def stub_notify_sms
    sms_client = mock_notify_sms_client
    allow(sms_client).to receive(:send_sms)
    sms_client
  end
end

class EmailAuditListComponentPreview < ViewComponent::Preview
  def default
    render(Support::EmailAuditListComponent.new(mock_audit))
  end

private

  def mock_audit
    [OpenStruct.new({ template: SecureRandom.uuid,
                      created_at: Time.zone.now,
                      user: OpenStruct.new({ full_name: 'Ken Block' }),
                      email_address: 'ken.block@example.com',
                      message_type: 'user_can_order_but_action_needed' }),
     OpenStruct.new({ template: SecureRandom.uuid,
                      created_at: Time.zone.now - 5.minutes,
                      user: OpenStruct.new({ full_name: 'Ken Block' }),
                      email_address: 'ken.block@example.com',
                      message_type: 'user_can_order' }),
     OpenStruct.new({ template: SecureRandom.uuid,
                      created_at: Time.zone.now - 15.minutes,
                      user: OpenStruct.new({ full_name: 'Sally Block' }),
                      email_address: 'ken.block@example.com',
                      message_type: 'nudge_rb_to_add_school_contact' })]
  end
end

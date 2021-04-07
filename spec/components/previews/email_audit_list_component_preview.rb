class EmailAuditListComponentPreview < ViewComponent::Preview
  def default
    audits = FactoryBot.build_list(:email_audit, 3, created_at: 3.days.ago)
    render(Support::EmailAuditListComponent.new(audits))
  end
end

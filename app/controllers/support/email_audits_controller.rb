class Support::EmailAuditsController < Support::BaseController
  before_action { authorize EmailAudit }

  def index
    @email_audits = EmailAudit.problematic.order(id: :desc).limit(300)
  end
end

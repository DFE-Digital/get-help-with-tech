class PrivacyNoticePolicy < ApplicationPolicy
  def seen?
    user == record # can only accept your own privacy notice
  end
end

class Personas::SupportUser
  def call
    support_user
  end

private

  def support_user
    @support_user ||= User.find_or_create_by!(email_address: 'support.user.1@example.com') do |u|
      u.full_name = 'Bill Gates'
      u.is_support = true
    end
  end
end

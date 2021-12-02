class CreateAdminUsersService
  def initialize(emails, user_type = :support)
    raise 'user_type must be :support or :supplier' unless %i[support supplier].include?(user_type)

    @emails = Array(emails)
    @user_type = user_type
  end

  def create!
    @emails.each do |email|
      email.downcase!
      email.strip!
      user = User.find_or_create_by!(email_address: email) do |u|
        u.full_name = name_from_email(email)
      end
      user.is_computacenter = true if @user_type == :supplier
      user.is_support = true if @user_type == :support
      user.save!
    end
  end

private

  def name_from_email(email)
    email.split('@').first.split('.').map(&:capitalize).join(' ')
  end
end

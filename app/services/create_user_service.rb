class CreateUserService
  def call(full_name:, email_address:, responsible_body_name:)
    responsible_body = ResponsibleBody.find_by!(name: responsible_body_name)
    User.create!(
      full_name: full_name,
      email_address: email_address,
      responsible_body: responsible_body,
      approved_at: Time.zone.now,
    )
  end
end

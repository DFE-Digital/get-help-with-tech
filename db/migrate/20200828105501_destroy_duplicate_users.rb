class DestroyDuplicateUsers < ActiveRecord::Migration[6.0]
  def change
    duplicate_users = User.where(
      'exists(
        select id from users u2  where  u2.id != users.id
                                    and u2.email_address = LOWER(users.email_address)
      )',
    )
    log "Found #{duplicate_users.count} duplicate_users"
    duplicate_users.each do |user|
      lowercase_user = User.where('id != ? and email_address = LOWER(?)', user.id, user.email_address).first
      # delete the one with the lowest sign-in count
      log "#{lowercase_user.email_address} sign_in_count: #{lowercase_user.sign_in_count}, #{user.email_address} sign_in_count: #{user.sign_in_count}"
      if lowercase_user.sign_in_count > user.sign_in_count
        log "=> destroying #{user.email_address}"
        user.destroy!
      else
        log "=> destroying #{lowercase_user.email_address}"
        lowercase_user.destroy!
      end
    end

    User.update_all('email_address = LOWER(email_address)')
  end

  def log(msg)
    Rails.logger.info msg
  end
end

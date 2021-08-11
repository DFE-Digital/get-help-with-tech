class DeleteUserService
  # Due CC needing to sync "Removed" users, just soft-delete accounts with
  # `techsource_account_confirmed_at` to keep a record of TS accounts as a precaution.
  # We can probably hard-delete in future them as "Removal" is recorded
  # in `Computacenter::UserChange`

  # Retroactively hard destroy already soft-deleted accounts, run in console:
  # User.deleted.where(techsource_account_confirmed_at: nil).each { |u| u.destroy! }

  def self.delete!(user)
    if user.techsource_account_confirmed_at
      user.update!(deleted_at: Time.zone.now, orders_devices: false)
    else
      user.destroy!
    end
  end
end

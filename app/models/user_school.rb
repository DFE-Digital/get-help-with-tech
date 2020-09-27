class UserSchool < ApplicationRecord
  belongs_to :user
  belongs_to :school

  after_save do |user_school|
    # Need to reload to pick up the new school, otherwise the cached value
    # from before the change will be used
    Computacenter::UserChangeGenerator.new(user_school.user).generate!
    if user_school.saved_change_to_attribute?(:user_id)
      previous_user_id = user_school.saved_change_to_attribute(:user_id).first
      if previous_user_id
        previous_user = User.find(previous_user_id)
        Computacenter::UserChangeGenerator.new(previous_user).generate!
      end
    end
  end

  after_destroy do |user_school|
    Computacenter::UserChangeGenerator.new(user_school.user.reload).generate!
  end
end

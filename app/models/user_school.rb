class UserSchool < ApplicationRecord
  belongs_to :user
  belongs_to :school, touch: true

  after_save do |user_school|
    user_school.user.generate_user_change_if_needed!
    if user_school.saved_change_to_attribute?(:user_id)
      previous_user_id = user_school.saved_change_to_attribute(:user_id).first
      if previous_user_id
        previous_user = User.find(previous_user_id)
        previous_user.generate_user_change_if_needed!
      end
    end
  end

  after_destroy do |user_school|
    user_school.user.generate_user_change_if_needed!
    user_school.user.destroy_school_welcome_wizard!(user_school.school)
  end
end

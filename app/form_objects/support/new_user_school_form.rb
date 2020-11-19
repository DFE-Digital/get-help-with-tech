class Support::NewUserSchoolForm
  include ActiveModel::Model

  attr_accessor :user, :name_or_urn

  def initialize(user:, name_or_urn: nil)
    @user = user
    @name_or_urn = name_or_urn
  end

  def matching_schools
    School.includes(:user_schools)
          .where('urn = ? OR LOWER(name) LIKE(?)', @name_or_urn.to_i, "%#{@name_or_urn.downcase}%")
          .order(:name)
  end
end

class Support::UserResponsibleBodyForm
  include ActiveModel::Model

  attr_accessor :user, :name

  def initialize(user:, name: nil)
    @user = user
    @name = name
  end

  def matching_responsible_bodies
    ResponsibleBody.where('name ILIKE(?)', "%#{@name}%")
                   .order(:name)
  end
end

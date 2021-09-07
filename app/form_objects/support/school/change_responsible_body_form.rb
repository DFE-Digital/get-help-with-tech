class Support::School::ChangeResponsibleBodyForm
  include ActiveModel::Model

  attr_accessor :school
  attr_writer :responsible_body_id, :responsible_body

  validates :school, presence: true
  validates :responsible_body, presence: true

  def responsible_body_id
    @responsible_body_id || school&.responsible_body_id
  end

  def responsible_body
    @responsible_body ||= ResponsibleBody.find_by_id(responsible_body_id)
  end

  def responsible_body_options
    @responsible_body_options ||= responsible_bodies.map do |id, name|
      OpenStruct.new(id: id, name: name)
    end
  end

  def save
    valid? && ChangeSchoolResponsibleBodyService.new(school, responsible_body).call
  end

private

  def responsible_bodies
    ResponsibleBody.gias_status_open.order(type: :asc, name: :asc).pluck(:id, :name)
  end
end

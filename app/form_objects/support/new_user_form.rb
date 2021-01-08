class Support::NewUserForm
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  attr_accessor :responsible_body, :school

  def submission_path
    if @school
      support_school_users_path(@school)
    elsif @responsible_body
      support_responsible_body_users_path(@responsible_body)
    end
  end

  def breadcrumbs_to_page
    if @school
      [
        { 'Support home' => support_home_path },
        { I18n.t('page_titles.support_responsible_bodies') => support_responsible_bodies_path },
        { @school.responsible_body.name => support_responsible_body_path(@school.responsible_body) },
        { @school.name => support_school_path(urn: @school.urn) },
      ]
    elsif @responsible_body
      [
        { 'Support home' => support_home_path },
        { I18n.t('page_titles.support_responsible_bodies') => support_responsible_bodies_path },
        { @responsible_body.name => support_responsible_body_path(@responsible_body) },
      ]
    end
  end
end

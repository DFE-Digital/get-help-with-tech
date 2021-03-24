class School::SchoolBreadcrumbsComponent < ViewComponent::Base
  attr_accessor :user, :school, :items

  def initialize(user:, school:, items:)
    @user = user
    @school = school
    @items = items
  end

  def breadcrumbs(items)
    items.map { |k, _v| k.is_a?(Hash) ? k : { k => '' } }.inject(:merge)
  end

  def scoped_breadcrumbs
    breadcrumbs(scope + Array(items))
  end

  def scope
    if user.responsible_body.present? && !user.is_a_single_school_user?
      responsible_body_and_school_scope
    elsif user.has_multiple_schools?
      multiple_schools_scope
    else
      single_school_scope
    end
  end

  def single_school_scope
    [
      { 'Home' => root_path },
      { 'Your account' => home_school_path(school) },
    ]
  end

  def multiple_schools_scope
    [
      { 'Your schools' => schools_path },
      { school.name => home_school_path(school) },
    ]
  end

  def responsible_body_and_school_scope
    [
      { 'Your organisations' => schools_path },
      { school.name => home_school_path(school) },
    ]
  end
end

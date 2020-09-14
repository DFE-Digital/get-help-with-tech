class SignInAsUserOrganisationForm
  include ActiveModel::Model

  attr_accessor :user_organisation_id
  attr_accessor :user, :schools, :trusts, :local_authorities

  validates :user_organisation_id, { presence: true }

  def initialize(params = {})
    @user = params[:user]
    cache_relations! if @user.present?

    @user_organisation_id = params[:user_organisation_id]
  end

  def cache_relations!
    @schools = @user.user_organisations.schools
    @trusts = @user.user_organisations.responsible_bodies.select{|org| org.organisation.type == 'Trust'}
    @local_authorities = @user.user_organisations.responsible_bodies.select{|org| org.organisation.type == 'LocalAuthority'}
  end
end

class Support::PrivilegedUsersController < Support::BaseController
  before_action { authorize :PrivilegedUser }

  def index
    @computacenter_users = User.where(is_computacenter: true)
    @support_users = User.where(is_support: true)
    @mno_users = User.where('mobile_network_id IS NOT NULL')
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])

    if @user.update(is_support: false, role: 'no', is_computacenter: false, mobile_network_id: nil)
      flash[:success] = "Privileges for #{@user.email_address} have been removed"
      redirect_to support_privileged_users_path
    else
      flash[:warning] = 'Privileges could not be removed'
      render :show
    end
  end

  def new
    @form_object = Support::PrivilegedUserForm.new
  end

  def create
    @form_object = Support::PrivilegedUserForm.new(form_params)

    if @form_object.valid?
      @form_object.create_user!
      flash[:success] = 'User has been added'
      redirect_to support_privileged_users_path
    else
      render :new
    end
  end

private

  def form_params
    params.require(:support_privileged_user_form).permit(:full_name, :email_address, privileges: [])
  end
end

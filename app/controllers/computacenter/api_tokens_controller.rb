class Computacenter::APITokensController < Computacenter::BaseController
  def index
    @api_tokens = @user.api_tokens.order('created_at DESC')
    @api_token = @user.api_tokens.build
  end

  def create
    @api_token = @user.api_tokens.build(api_token_params)
    if @api_token.valid?
      @api_token.save!
      redirect_to computacenter_api_tokens_path
    else
      @api_tokens = @user.api_tokens.order('created_at DESC')
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @api_token = @user.api_tokens.find(params[:id])
    if @api_token.update!(api_token_params)
      redirect_to computacenter_api_tokens_path
    else
      @api_tokens = @user.api_tokens.order('created_at DESC')
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @api_token = @user.api_tokens.find(params[:id])
    @api_token.destroy!
    flash[:success] = I18n.t(:success, scope: %i[computacenter api_tokens destroy], name: @api_token.name)
    redirect_to computacenter_api_tokens_path
  end

private

  def api_token_params(opts = params)
    opts.require(:api_token).permit(:name, :status)
  end
end

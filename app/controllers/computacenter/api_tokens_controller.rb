class Computacenter::APITokensController < Computacenter::BaseController
  def index
    @api_tokens = @user.api_tokens.order('created_at DESC')
  end
end

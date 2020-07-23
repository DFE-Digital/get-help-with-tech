module CapybaraHelper
  def basic_auth!(username:, password:)
    encoded_login = ["#{username}:#{password}"].pack('m*')
    page.driver.header 'Authorization', "Basic #{encoded_login}"
  end

  def sign_in_as(user)
    visit validate_token_url_for(user)
    click_on 'Continue'
  end

  def validate_token_url_for(user)
    token = user.generate_token!
    identifier = user.sign_in_identifier(token)
    validate_sign_in_token_url(token: token, identifier: identifier)
  end
end

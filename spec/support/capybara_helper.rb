module CapybaraHelper
  def basic_auth!(username:, password:)
    encoded_login = ["#{username}:#{password}"].pack('m*')
    page.driver.header 'Authorization', "Basic #{encoded_login}"
  end
end

class VCapServicesConfig
  attr_accessor :config

  def initialize(config = ENV['VCAP_SERVICES'])
    @config = JSON.parse(ENV['VCAP_SERVICES'])
  end

  def first_service_matching(name)
    service_key = @config.keys.find { |svc| svc =~ Regexp.new("/#{name}/i") }
    @config[redis_service_name].first
  end
end

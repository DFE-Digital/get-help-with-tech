class VCapServicesConfig
  attr_accessor :config

  def initialize(config = ENV['VCAP_SERVICES'])
    @config = JSON.parse(config)
  end

  def first_service_matching(name)
    service_key = @config.keys.find { |svc| svc =~ Regexp.new("/#{name}/i") }
    @config[service_key].first
  end
end

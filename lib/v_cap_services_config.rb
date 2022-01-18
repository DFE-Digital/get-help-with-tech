class VCapServicesConfig
  attr_accessor :config

  def initialize(config = ENV['VCAP_SERVICES'])
    @config = JSON.parse(config) if config.present?
  end

  def first_service_matching(name)
    return unless config

    service_key = @config.keys.find { |svc| svc =~ /#{name}/i }
    @config[service_key].first
  end
end

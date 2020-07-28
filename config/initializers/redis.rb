# on CloudFoundry (i.e. Gov.uk PaaS) we don't get a nice neat REDIS_URL
# we have to interrogate the bound services to get our config
if ENV['VCAP_SERVICES']
  $vcap_services ||= JSON.parse(ENV['VCAP_SERVICES'])
  redis_service_name = $vcap_services.keys.find { |svc| svc =~ /redis/i }
  redis_service = $vcap_services[redis_service_name].first
  $redis_config = {
    host: redis_service['credentials']['host'],
    port: redis_service['credentials']['port'],
    password: redis_service['credentials']['password'],
    ssl: redis_service['credentials']['tls_enabled'],
    db: 1
  }
else
  $redis_config = {
    host: '127.0.0.1',
    port: 6379,
    db: 1
  }
end

$redis = Redis.new($redis_config)

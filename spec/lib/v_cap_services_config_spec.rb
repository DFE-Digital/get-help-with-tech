require 'rails_helper'
require 'v_cap_services_config'

describe VCapServicesConfig do
  let(:config) do
    <<~VCAP_SERVICES_VAR
      {"user-provided":[{
        "label": "user-provided",
        "name": "logit-ssl-drain",
        "tags": [

        ],
        "instance_name": "logit-ssl-drain",
        "binding_name": null,
        "credentials": {

        },
        "syslog_drain_url": "syslog-tls://some-key-ls.logit.io:27502",
        "volume_mounts": [

        ]
      }],"postgres":[{
        "label": "postgres",
        "provider": null,
        "plan": "tiny-unencrypted-11",
        "name": "get-help-with-tech-staging-db",
        "tags": [
          "postgres",
          "relational"
        ],
        "instance_name": "get-help-with-tech-staging-db",
        "binding_name": null,
        "credentials": {
          "host": "rdsbroker-something.eu-west-2.rds.amazonaws.com",
          "port": 5432,
          "name": "rdsbroker_something",
          "username": "some-random-string",
          "password": "some-other-random-string",
          "uri": "postgres://some-random-string:some-other-random-string@rdsbroker-something.eu-west-2.rds.amazonaws.com:5432/rdsbroker_2c61cddf_0396_46d7_8ff6_5847e3cbd85b",
          "jdbcuri": "jdbc:postgresql://rdsbroker-something.eu-west-2.rds.amazonaws.com:5432/rdsbroker_something?password=some-other-random-string&ssl=true&user=some-random-string"
        },
        "syslog_drain_url": null,
        "volume_mounts": [

        ]
      }]}
    VCAP_SERVICES_VAR
  end
  let(:config_object) { VCapServicesConfig.new(config) }

  describe '#first_service_matching' do
    it 'matches the given full name' do
      expect(config_object.first_service_matching('postgres')).not_to be_nil
    end

    it 'matches a partial name' do
      expect(config_object.first_service_matching('post')).not_to be_nil
    end

    it 'matches a partial name with different case' do
      expect(config_object.first_service_matching('Gres')).not_to be_nil
    end
  end
end

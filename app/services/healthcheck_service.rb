class HealthcheckService
  SERVICES = %i[db redis].freeze

  def self.run
    all_services_status = services_status
    {
      status: (all_services_status.values.all?('UP') ? 'UP' : 'DOWN'),
      services: all_services_status,
      info: {
        git: git_info,
        docker: docker_info,
      },
    }
  end

  def self.docker_info
    {
      image_id: ENV['DOCKER_IMAGE_ID'],
    }
  end

  def self.git_info
    {
      commit_sha: ENV['GIT_COMMIT_SHA'],
      branch: ENV['GIT_BRANCH'],
    }
  end

  def self.services_status
    status = {}
    SERVICES.each do |service|
      status[service] = status_of(service)
    end
    status
  end

  # TODO: refactor when we have more than one service
  # Maybe have separate XYZHealthcheck classes?
  def self.status_of(service)
    case service
    when :db then db_status
    when :redis then redis_status
    end
  rescue StandardError
    'DOWN'
  end

  def self.db_status
    ExtraMobileDataRequest.maximum(:created_at)
    'UP'
  end

  def self.redis_status
    Sidekiq.redis_info['redis_version']
    'UP'
  end
end

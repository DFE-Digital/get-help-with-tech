# Allows child services to be called without explicit instantiation
class ApplicationService
  def self.call(*args, **keyword_args, &block)
    new(*args, **keyword_args, &block).call
  end
end

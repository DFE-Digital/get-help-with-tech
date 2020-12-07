class Computacenter::MultiDomainChromebooksController < Computacenter::BaseController
  def index
    @responsible_bodies = ResponsibleBody.managing_multiple_chromebook_domains
  end
end

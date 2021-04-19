namespace :db do
  desc 'Add tests personas to database'
  task personas: :environment do
    Personas::SupportUser.new.call
    Personas::TrustWithSchools.new.call
    Personas::LaFundedPlace.new.call
  end
end

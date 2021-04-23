namespace :import do
  desc 'Add tests personas to database'
  task personas: :environment do
    puts 'Setting up Persona test accounts'
    Personas::SupportUser.new.call
    Personas::TrustWithSchools.new.call
    Personas::LaFundedPlace.new.call
  end
end

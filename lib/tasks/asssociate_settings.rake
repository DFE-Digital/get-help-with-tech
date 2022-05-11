namespace :associate_settings do
  desc 'find out the associated school/rb for assets still not associated and link them'
  task to_assets: :environment do
    Computacenter::AssociateSettingsToAssetsService.call
  end

  desc 'find out the associated school/rb for orders still not associated and link them'
  task to_orders: :environment do
    Computacenter::AssociateSettingsToOrdersService.call
  end
end

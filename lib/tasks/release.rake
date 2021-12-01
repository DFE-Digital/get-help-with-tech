namespace :release do
  desc 'Render 429.html error page to the public folder'
  task render_429_to_file: :environment do
    renderer = ApplicationController.renderer.new(
      http_host: Settings.hostname_for_urls,
    )
    content = renderer.render(template: 'errors/too_many_requests')
    path = Rails.root.join('public/429.html')
    File.open(path, 'w+') do |f|
      f << content
    end
    puts "Rendered #{content.length} bytes to #{path}"
  end
end

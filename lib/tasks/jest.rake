namespace :test do
  desc 'Run JS unit tests'
  task :jest do
    sh 'yarn jest --coverage'
  end
end

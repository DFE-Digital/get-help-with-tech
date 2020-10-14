# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

Rake::Task[:default].clear

task lint_ruby: ['lint:ruby']
task lint_scss: ['lint:scss']
task test_js: ['test:jest']
task parallel_spec: ['parallel:spec']
task default: %i[lint_ruby lint_scss parallel_spec test_js]

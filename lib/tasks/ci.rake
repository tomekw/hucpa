require "rubocop/rake_task"

namespace :ci do
  RuboCop::RakeTask.new(:rubocop)

  desc "Run all CI checks"
  task run: %i[rubocop spec]
end

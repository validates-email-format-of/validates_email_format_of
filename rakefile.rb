require "bundler/gem_tasks"
require "standard/rake"

task default: [:spec, "standard:fix"]

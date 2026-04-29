# frozen_string_literal: true

require 'rubygems/server'

gem_dir = File.expand_path('../server/gem', __dir__)
puts "gem_dir: #{gem_dir}"

gem_server = Gem::Server.new gem_dir, 18_808, false
gem_server.run

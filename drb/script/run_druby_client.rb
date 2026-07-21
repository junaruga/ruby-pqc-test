#!/usr/bin/env ruby
# frozen_string_literal: true

require 'drb/drb'

# The URI to connect to
SERVER_URI = 'druby://localhost:8787'

# Start a local DRbServer to handle callbacks.

# Not necessary for this small example, but will be required
# as soon as we pass a non-marshallable object as an argument
# to a dRuby call.

# NOTE: this must be called at least once per process to take any effect.
# This is particularly important if your application forks.
DRb.start_service

timeserver = DRbObject.new_with_uri(SERVER_URI)
puts timeserver.current_time

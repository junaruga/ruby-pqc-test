#!/usr/bin/env ruby
# frozen_string_literal: true

require 'drb/drb'

# The URI for the server to connect to
URI = 'druby://localhost:8787'

# A simple time server for testing druby.
class TimeServer
  def current_time
    Time.now
  end
end

# The object that handles requests on the server
FRONT_OBJECT = TimeServer.new

DRb.start_service(URI, FRONT_OBJECT)
# Wait for the drb server thread to finish before exiting.
DRb.thread.join

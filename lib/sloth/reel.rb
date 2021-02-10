require "sloth/reel/version"
#require "celluloid/current"
require "celluloid/autostart"
require "celluloid/fsm"
require "reel/rack"
require "sinatra/base"
require "sloth/reel/sinatra"

module Sloth
  module Reel
    class Error < StandardError; end
  end
end

require "sinatra/base"

module Sloth
  module Reel
    module Sinatra
      def websocket?
        !!env['websocket']
      end

      def websocket
        env['websocket']
      end
    end
  end
end

defined?( ::Sinatra ) && Sinatra::Request.send( :include, ::Sloth::Reel::Sinatra )


require 'sloth/reel'

class WebApp < Sinatra::Base

  get "/timeinfo" do
    if  request.websocket?
      Thread.start(request.websocket) do |ws|
        begin
          while  not ws.closed?
            mesg  =  Time.now.inspect
            ws.write( mesg )
            sleep  1
          end
        rescue  Reel::SocketError => e
          STDERR.puts  e.message
        end
      end
    end
  end

  get '/'  do
    <<~HTML
      <!doctype html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Reel WebSockets Time Server Example</title>
      </head>
      <script>
        var ws = new WebSocket('ws://' + window.location.host + '/timeinfo');
        ws.onmessage = function(mesg){
          document.getElementById('current-time').innerHTML = mesg.data;
        }
      </script>
      <body>
        <div id="content">
          <h1>Reel WebSockets Time Server Example</h1>
          <h2>The time is now: <span id="current-time">...</span></h2>
        </div>
      </body>
      </html>
    HTML
  end

end

ENV['RACK_ENV'] ||= 'production'
options  =  {Host: "0.0.0.0", Port: 3000}
Reel::Rack::Server.new( WebApp.new, options )

Signal.trap(:INT) do
  exit
end

sleep


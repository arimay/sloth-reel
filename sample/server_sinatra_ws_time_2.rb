require 'sloth/reel'

WebSockets  =  []

Thread.start do
  while  true
    sleep  1
    mesg  =  Time.now.inspect

    WebSockets.dup.each do |ws|
      begin
        ws.write( mesg )
      rescue  Reel::SocketError
        WebSockets.delete( ws )
      end
    end
  end
end

class WebApp < Sinatra::Base

  get "/timeinfo" do
    if  request.websocket?
      WebSockets  <<  request.websocket
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


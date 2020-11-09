require 'sloth/reel'

class WebServer < Reel::Server::HTTP
  include Celluloid::Internals::Logger

  def initialize( options )
    host  =  options[:Host] || "0.0.0.0"
    port  =  options[:Port] || 3000
    opts  =  {}
    opts[:max_connection]  =  options[:max_connection] || 16

    info  "Reel::Server starting on #{host}:#{port}"
    super( host, port, opts, &method(:on_connection) )
  end

  def on_connection(connection)
    while request = connection.request
      if request.websocket?
        connection.detach
        route_websocket( request )
      else
        route_request( connection, request )
      end
    end
  end

  def route_websocket( request )
    case  request.url
    when  "/timeinfo"
      route_timeinfo( request )
    end
  end

  def route_timeinfo(request)
    if request.websocket?
      Thread.start do
        begin
          websocket  =  request.websocket
          while not websocket.closed?
            str  =  Time.now.to_s
            websocket.write  str
            sleep  1
          end
        rescue  Reel::SocketError
        end
      end
    end
  end

  def route_request(connection, request)
    case  request.url
    when  "/"
      render_index(connection)
    else
      info "404 Not Found: #{request.path}"
      connection.respond :not_found, "Not found"
    end
  end

  def render_index(connection)
    info "200 OK: /"
    connection.respond :ok, <<-HTML
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

options  =  {Host: "0.0.0.0", Port: 3000, max_connection: 16}
WebServer.new( options )

Signal.trap(:INT) do
  exit
end

sleep


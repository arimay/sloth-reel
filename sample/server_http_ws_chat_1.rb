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
    when  "/chat"
      route_chat( request )
    end
  end

  def route_chat(request)
    if request.websocket?
      ws  =  request.websocket
      ws  <<  Time.now.to_s
      ws.on_message do |mesg, sender, conns|
        conns.each do |conn|
          conn  <<  mesg
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
      <html>
        <body>
          <h1>WebSocket Chat</h1>
          <form id="form"> <input type="text" id="input" value=""></input> </form>
          <div id="msgs"></div>
        </body>

        <script type="text/javascript">
          window.onload = function(){
            (function(){
              var show = function(el){
                return function(str){ el.innerHTML = str + '<br />' + el.innerHTML }
              }(document.getElementById('msgs'))

              ws = new WebSocket('ws://' + window.location.host + '/chat')
              ws.onopen = function() { show('[opened]') }
              ws.onclose = function() { show('[closed]') }
              ws.onmessage = function(mesg) { show(mesg.data) }

              var sender = function(fm) {
                var input = document.getElementById('input')
                input.onclick = function(){
                  input.value = ""
                }
                fm.onsubmit = function(){
                  ws.send( input.value )
                  input.value = ""
                  return false
                }
              }(document.getElementById('form'))
            })()
          }
        </script>
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

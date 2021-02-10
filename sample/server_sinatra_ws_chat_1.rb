require 'sloth/reel'

class WebApp < Sinatra::Base

  get '/chat' do
    if request.websocket?
      ws  =  request.websocket
      ws  <<  Time.now.to_s
      ws.on_message do |mesg, _sender, conns|
        conns.each do |conn|
          conn  <<  mesg
        end
      end
    end
  end

  get '/'  do
    <<~HTML
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

ENV['RACK_ENV'] ||= 'production'
options  =  {Host: "0.0.0.0", Port: 3000}
Reel::Rack::Server.new( WebApp.new, options )

Signal.trap(:INT) do
  exit
end

sleep


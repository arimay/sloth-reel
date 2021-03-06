require 'sloth/reel'

class WebApp < Sinatra::Base

  configure do
    enable :logging
    file  =  ::STDOUT
    file.sync  =  true
    use  Rack::CommonLogger, file
  end

  def logger
    env['app.logger'] || env['rack.logger']
  end

  get  "/"  do
    logger.info  "get /"
    '<html><body>
       <h1> GET </h1>
       <a href="/"> (GET) </a>
       <form method="POST"><input type="submit" value="(POST)" /></form>
    </body></html>'
  end

  post  "/"  do
    logger.info  "post /"
    '<html><body>
       <h1> POST </h1>
       <a href="/"> (GET) </a>
       <form method="POST"><input type="submit" value="(POST)" /></form>
    </body></html>'
  end
end

ENV['RACK_ENV'] ||= 'production'
options  =  {Host: "0.0.0.0", Port: 3000}
Reel::Rack::Server.new( WebApp.new, options )

Signal.trap(:INT) do
  exit
end

sleep


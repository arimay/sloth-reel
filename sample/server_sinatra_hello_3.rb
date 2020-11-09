require 'sloth/reel'

class WebApp < Sinatra::Base

  def logger
    Reel::Logger.logger
  end

  get  "/"  do
    '<html><body>
       <h1> GET </h1><a href="/"> (GET) </a>
       <form method="POST"><input type="submit" value="(POST)" /></form>
    </body></html>'
  end

  post "/" do
    sec  =  5
    tm1  =  Time.now
    logger.info  format( "tm1: %s", tm1.to_s )
    ::Kernel.sleep  sec
    tm2  =  Time.now
    logger.info  format( "tm2: %s", tm2.to_s )
    logger.info  format( "%.3f", tm2 - tm1 )

    <<~HTML
      <html><body>
       <h1> POST </h1><a href="/"> (GET) </a>
       <form method="POST"><input type="submit" value="(POST)" /></form>
       <h1> Delay, wait sec: #{sec}</h1>
       <p> #{tm1}: sleep <br/> #{tm2}: wakeup </p>
      </body></html>
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


require 'sloth/reel'

class WebApp
  def call( env )
    case env['REQUEST_METHOD']
    when 'GET'
      case  env['PATH_INFO']
      when  '/'
        get_index
      when  '/heavy'
        get_heavy
      end

    when 'POST'
      case  env['PATH_INFO']
      when  '/'
        post_index
      end

    else
      not_found

    end
  end

  def not_found
    [
      404,
      {'Content-Type' => 'text/html'},
      ["<html><body><h1> 404: Not found: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} </h1> </body></html>"]
    ]
  end

  def get_index
    [
      200,
      {'Content-Type' => 'text/html'},
      ['<html><body><h1> GET </h1><a href="/"> Hello (GET) </a> <form method="POST"><input type="submit" value="Howdy (POST)" /></form></body></html>']
    ]
  end

  def post_index
    [
      200,
      {'Content-Type' => 'text/html'},
      ['<html><body><h1> POST </h1><a href="/"> Hello (GET) </a> <form method="POST"><input type="submit" value="Howdy (POST)" /></form></body></html>']
    ]
  end

  def get_heavy
    sec  =  10
    tm1  =  Time.now.to_s
    Kernel.sleep  sec
    tm2  =  Time.now.to_s

    [
      200,
      {'Content-Type' => 'text/html'},
      ["<html><body><p> #{sec}: interval <br/> #{tm1}: sleep <br/> #{tm2}: wakeup </p></body></html>"]
    ]
  end
end

ENV['RACK_ENV'] ||= 'production'
options  =  {Host: "0.0.0.0", Port: 3000, max_connection: 16}
Reel::Rack::Server.new( WebApp.new, options )

Signal.trap(:INT) do
  exit
end

sleep


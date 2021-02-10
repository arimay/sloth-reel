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

  def on_connection( connection )
    while ( request = connection.request )
      route_request  connection, request
    end
  end

  def route_request( connection, request )
    case  request.method
    when  "GET"
      case  request.url
      when  "/"
        get_index( connection )
      when  "/heavy"
        get_heavy( connection )
      end

    when  "POST"
      case  request.url
      when  "/"
        post_index( connection )
      end

    else
      not_found( connection )

    end
  end

  def not_found( connection )
    info "404 Not Found: #{request.method} #{request.path}"
    connection.respond :not_found, "Not found"
  end

  def get_index( connection )
    info "200 OK: GET /"
    connection.respond :ok, <<-HTML
      <html><body><h1> GET </h1><a href="/"> Hello (GET) </a> <form method="POST"><input type="submit" value="Howdy (POST)" /></form></body></html>
    HTML
  end

  def post_index( connection )
    info "200 OK: POST /"
    connection.respond :ok, <<-HTML
      <html><body><h1> POST </h1><a href="/"> Hello (GET) </a> <form method="POST"><input type="submit" value="Howdy (POST)" /></form></body></html>
    HTML
  end

  def get_heavy( connection )
    info "200 OK: POST /"

    sec  =  10
    tm1  =  Time.now.to_s
    Kernel.sleep  sec
    tm2  =  Time.now.to_s

    connection.respond :ok, <<-HTML
      <html><body><p> #{sec}: interval <br/> #{tm1}: sleep <br/> #{tm2}: wakeup </p></body></html>
    HTML
  end
end

options  =  {Host: "0.0.0.0", Port: 3000, max_connection: 16}
WebServer.new( options )

Signal.trap(:INT) do
  exit
end

sleep

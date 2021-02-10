module Reel
  # Base class for Reel servers.
  #
  # This class is a Celluloid::IO actor which provides a barebones server
  # which does not open a socket itself, it just begin handling connections once
  # initialized with a specific kind of protocol-based server.

  # For specific protocol support, use:

  # Reel::Server::HTTP
  # Reel::Server::HTTPS
  # Coming soon: Reel::Server::UNIX

  class Server
    include Celluloid::IO
    # How many connections to backlog in the TCP accept queue
    DEFAULT_BACKLOG = 100
    MAX_CONNECTION = 16

    execute_block_on_receiver :initialize
    finalizer :shutdown

    def initialize(server, options={}, &callback)
      @spy      = STDOUT if options[:spy]
      @options  = options
      @callback = callback
      @server   = server
      @max_connection  =  options[:max_connection] || MAX_CONNECTION

      @server.listen(options.fetch(:backlog, DEFAULT_BACKLOG))

      async.run
    end

    def shutdown
      @server.close if @server
      info  "Terminate."
    end

    def run
      queue  =  Queue.new
      (1..@max_connection).each do
        Thread.start do
          Thread.current.report_on_exception = false    rescue  nil
          while ( sock = queue.pop )
            handle_connection  sock
          end
        end
      end
      info  "Ready."
      loop do
        queue.push  @server.accept
      end
    ensure
      info  "Terminate."
    end

    def handle_connection(socket)
      if @spy
        require 'reel/spy'
        socket = Reel::Spy.new(socket, @spy)
      end

      connection = Connection.new(socket)

      begin
        @callback.call(connection)
      ensure
        if connection.attached?
          connection.close rescue nil
        end
      end
    rescue RequestError, EOFError
      # Client disconnected prematurely
      # TODO: log this?
    end
  end
end

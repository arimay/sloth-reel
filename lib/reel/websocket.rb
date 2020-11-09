require 'forwardable'
require 'websocket'

module Reel
  class WebSocket
    extend Forwardable
    include ConnectionMixin
    include RequestMixin

    attr_reader :socket, :url
    def_delegators :@socket, :addr, :peeraddr

    READ_SIZE  =  0x4000
    @@sockets  =  []
    @@conns  =  {}
    @@actions  =  Hash.new { |h,k| h[k] = {} }
    @@thread  =  nil

    def initialize(info, connection)
      @opened  =  false
      @socket  =  connection.hijack_socket
      @request_info  =  info
      @url  =  @request_info.url

      @handshake  =  ::WebSocket::Handshake::Server.new
      @frame  =  ::WebSocket::Frame::Incoming::Server.new(:version => @handshake.version)

      line  =  "#{@request_info.method} / HTTP/#{@request_info.version}\r\n"
      @handshake  <<  line
      @request_info.headers.each do |k, v|
        line  =  "#{k}: #{v}\r\n"
        @handshake  <<  line
      end
      @handshake  <<  "\r\n"

      if not @handshake.finished? or not @handshake.valid?
        @socket.close
        return
      end

      lines  =  @handshake.to_s
      @socket.write  lines

      @@sockets.push( @socket )
      @@conns[@socket]  =  self

      @@thread  ||=  Thread.start do
        loop do
          readables,  =  ::IO.select( @@sockets, nil, nil, 1 )
          while  sock  =  readables&.shift
            if sock.eof?
              @@conns[sock]&.close
              break
            else
              payload  =  sock.readpartial( READ_SIZE )    rescue  nil
              @@conns[sock]&.parse( payload )    if  payload
            end
          end
        end
      end

    end

    def parse( payload )
      @frame  <<  payload
      messages  =  []
      while  frame = @frame.next
        if (frame.type == :close)
          close
          break
        else
          messages.push  frame.to_s
        end
      end

      conns  =  @@conns.values.map do |conn|
        conn    if  conn.url == @url
      end.compact
      messages.each do |mesg|
        @@actions[@url][:onmessage]&.call( mesg, self, conns )    rescue  nil
      end
    end

    def send( mesg, type: :text )
      frame  =  ::WebSocket::Frame::Outgoing::Server.new( :version => @handshake.version, :data => mesg, :type => type )
      begin
        @socket.write  frame.to_s
        @socket.flush
      rescue
        close
        raise  Reel::SocketError
      end
    end
    alias  write  send
    alias  :<<    send

    def close
      return    if  @socket.closed?
      @@actions[@url][:onclose]&.call( self )    rescue  nil
      @@conns.delete( @socket )
      @@sockets.delete( @socket )
      @@sockets.compact!
      @socket.close    rescue  nil
    end

    def closed?
      @socket.closed?
    end

    def connections
      @@conns.values
    end

    def on_open( &block )
      @@actions[@url][:onopen]  =  block
      if  not @opened
        @opened  =  true
        block.call( self )    rescue  nil
      end
    end

    def on_message( &block )
      @@actions[@url][:onmessage]  =  block
    end

    def on_close( &block )
      @@actions[@url][:onclose]  =  block
    end

  end
end


require 'socket'
require 'parseconfig'
require 'logger'


require_relative 'webmail_server/answer_worker'
require_relative 'webmail_server/request'
require_relative 'webmail_server/response'

module WebMailServer

  SERVER_ROOT = "#{File.expand_path(File.dirname(__FILE__))}/assets/"

  # Starts and initiates the HTTP server
  class HTTPServer
    attr_reader :config_path, :server_root, :port

    # Initializes the HTTP server
    #
    # @param port [Integer] The port the server listens to
    # @param server_root [String] The directory the server points to
    def initialize(port)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      @port = port
    end

    # Starts the server ready to accept new connections
    def start
      @logger.debug { "Opening server" }
      @tcp_server = TCPServer.new("0.0.0.0", @port)
      @logger.debug { "Listening to 0.0.0.0 port #{@port}
                      pointing #{SERVER_ROOT}" }
      answer_worker = AnswerWorker.new
      client = nil
      loop do
        client = @tcp_server.accept
        @logger.debug { "Server accepted" }
        answer_worker.start(client)
      end
      stop
    end

    # Close server
    def stop
      @tcp_server.close
      @logger.debug { "Server Closed" }
    end

  end
end



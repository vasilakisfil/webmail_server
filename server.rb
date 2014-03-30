require_relative 'lib/webmail_server'
require_relative 'lib/webmail_server/response'

server = WebMailServer::HTTPServer.new(5555)

server.start



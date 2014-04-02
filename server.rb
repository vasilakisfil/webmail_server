require_relative 'lib/webmail_server'
require_relative 'lib/webmail_server/response'

WebMailServer::HTTPServer.new(5555).start

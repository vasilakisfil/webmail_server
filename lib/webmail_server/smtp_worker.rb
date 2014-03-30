require 'socket'

module WebMailServer

  class SMTPWorker
    attr_accessor :opts

    def initialize(opts={})
      opts["server"]        ||= WebMailServer::SMTP_SERVER
      opts["HELO"]          ||= "client.smtp.ik2213.lab"
      opts["from"]          ||= 'email@kth.se'
      opts["to"]            ||= 'fvas@kth.se'
      opts["subject"]       ||= "This is the subject"
      opts["message"]       ||= "Watch out in KTH !"
      opts["port"]          ||= 25
      @opts = opts
      fix_mails_for_smtp
      create_write_operations
      @log = "Initializing connection..\n"
    end

    #add safety/validation by checking answer OK"
    #add better error log to be shown in the response html
    def send_email
      begin
        open_socket
        write_helo
        write_mail_from
        write_mail_to
        write_mail_data
        write_quit
      rescue => exception
        @log += exception.inspect + "\n"
      end
      return @log
    end

    private

    def create_write_operations
      @write_opts = {}
      @write_opts[:helo] = "HELO #{opts["HELO"]}"
      @write_opts[:from] = "MAIL from: #{opts["from"]}"
      @write_opts[:to] = "RCPT to: #{opts["to"]}"
      @write_opts[:data] = "DATA\n"
      @write_opts[:body] = "Subject: #{opts["subject"]}\n\n"
      @write_opts[:body] += "#{opts["message"]}\r\n.\r\n"
      @write_opts[:quit] = "QUIT"
    end

    def fix_mails_for_smtp
      opts["from"] = "<#{opts["from"]}>"
      opts["to"] = "<#{opts["to"]}>"
    end

    def open_socket
      @socket = TCPSocket.open(@opts["server"], @opts["port"])
      @log += read_socket(@socket) + "\n"
    end

    def write_helo
      @log += @write_opts[:helo] + "\n"
      @socket.puts(@write_opts[:helo])
      @log += read_socket(@socket) + "\n"
    end

    def write_mail_from
      @log += @write_opts[:from] + "\n"
      @socket.puts(@write_opts[:from])
      @log += read_socket(@socket) + "\n"
    end

    def write_mail_to
      @log += @write_opts[:to] + "\n"
      @socket.puts(@write_opts[:to])
      @log += read_socket(@socket) + "\n"
    end

    def write_mail_data
      @log += @write_opts[:data] + "\n"
      @socket.puts(@write_opts[:data])
      @log += read_socket(@socket) + "\n"
      @log += @write_opts[:body] + "\n"
      @socket.puts(@write_opts[:body])
      @log += read_socket(@socket) + "\n"
    end

    def write_quit
      @log += @write_opts[:quit] + "\n"
      @socket.puts("QUIT")
      @log += read_socket(@socket) + "\n"
    end

    def read_socket(socket)
      input = nil
      begin
        input = socket.read_nonblock(5000)
      rescue Errno::EAGAIN
        retry
      end
    end
  end
end

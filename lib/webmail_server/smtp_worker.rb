require 'socket'
require_relative 'qprintable'
require_relative 'mx_record'

module WebMailServer

  class SMTPWorker
    attr_accessor :opts

    def initialize(opts={})
      @logger = ::Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      opts["smtp_server"]   ||= MXRecord.mx_record(opts["to"]) || WebMailServer::SMTP_SERVER
      opts["HELO"]          ||= "client.smtp.ik2213.lab"
      opts["from"]          ||= 'email@kth.se'
      opts["to"]            ||= 'fvas@kth.se'
      opts["subject"]       ||= "This is the subject"
      opts["message"]       ||= "Watch out in KTH !"
      opts["port"]          ||= 25

      tmp = MXRecord.mx_record(opts["to"])
      if tmp
        opts["smtp_server"]= tmp
      end
      puts '------------------------------SMTP-SERVER----->>>' + opts["smtp_server"]
      @opts = opts

      fix_mails_for_smtp
      create_write_operations
      @log = "Initializing connection..\n"
    end


    #add safety/validation by checking answer OK"
    #add better error log to be shown in the response html
    def send_email
      @logger.debug { "=================== Sending email ===================" }
      @logger.debug { @opts }
      @logger.debug { "=================== Sending email ===================" }
      error = nil
      begin
        loop do
          open_socket
          write_helo
          err = write_mail_from
          (error = err; break) if !err.include? "Ok"
          err = write_mail_to
          (error = err; break) if !err.include? "Ok"
          err = write_mail_data
          (error = err; break) if !err.include? "Ok"
          write_quit
          break
        end
      rescue => exception
        error = exception.inspect + "\n"
        @log += exception.inspect + "\n"
      end
      puts @log
      return @log, error
    end

    private

    def create_write_operations
      @write_opts = {}
      @write_opts[:helo] = "HELO #{@opts["HELO"]}"
      @write_opts[:from] = "MAIL from: #{@opts["from"]}"
      @write_opts[:to] = "RCPT to: #{@opts["to"]}"
      @write_opts[:data] = "DATA\n"
      #sanitize to rfc2047
      begin
        new_subject = Qprintable.subjectRFC(opts["subject"])
      rescue
        puts '-----------------gamw tin panagia sou-----------'
        new_subject = 'subject failure'
      end
      @write_opts[:body] = "Subject: #{new_subject}\r\n"
#      @write_opts[:body] = "Subject: #{opts["subject"]}\r\n"
      #add mime headers and sanitize to quoted printable
      begin
        message = opts["message"]
        message.force_encoding(Encoding::UTF_8)
        message = Qprintable.sanitize(message, 70, 'utf', true)
        puts "Sending this message \n #{message}"
      rescue => e
        puts "something went wrong\n #{e.message} \m #{e.backtrace}"
      end
      @write_opts[:body] += "#{message}\r\n.\r\n"
      @write_opts[:quit] = "QUIT"
    end

    def fix_mails_for_smtp
      @opts["from"] = "<#{@opts["from"]}>"
      @opts["to"] = "<#{@opts["to"]}>"
    end

    def open_socket
      @socket = TCPSocket.open(@opts["smtp_server"], @opts["port"])
      log = read_socket(@socket) + "\n"
      @log += log
      return log
    end

    def write_helo
      @log += @write_opts[:helo] + "\n"
      @socket.puts(@write_opts[:helo])
      log = read_socket(@socket) + "\n"
      @log += log
      return log
    end

    def write_mail_from
      @log += @write_opts[:from] + "\n"
      @socket.puts(@write_opts[:from])
      log = read_socket(@socket) + "\n"
      @log += log
      return log
    end

    def write_mail_to
      @log += @write_opts[:to] + "\n"
      @socket.puts(@write_opts[:to])
      log = read_socket(@socket) + "\n"
      @log += log
      return log
    end

    def write_mail_data
      @log += @write_opts[:data] + "\n"
      @socket.puts(@write_opts[:data])
      @log += read_socket(@socket) + "\n"
      @log += @write_opts[:body] + "\n"
      @socket.puts(@write_opts[:body])
      log = read_socket(@socket) + "\n"
      @log += log
      return log
    end

    def write_quit
      @log += @write_opts[:quit] + "\n"
      @socket.puts("QUIT")
      log = read_socket(@socket) + "\n"
      @log += log
      return log
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

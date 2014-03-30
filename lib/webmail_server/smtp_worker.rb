require 'socket'

module WebMailServer

  class SMTPWorker
    attr_accessor :opts

    def initialize(opts={})
      opts["server"]       ||= WebMailServer::SMTP_SERVER
      opts["HELO"]         ||= "client.smtp.ik2213.lab"
      opts["from"]         ||= 'email@kth.se'
      opts["to"]           ||= 'fvas@kth.se'
      opts["subject"]      ||= "This is the subject"
      opts["body"]           = opts["message"] || "Watch out in KTH !"
      opts["port"]         ||= 25
      @opts = opts
      fix_mails_for_smtp
    end

    #add safety/validation by checking answer OK"
    def send_email
      log = ""
      begin
        log += open_socket
        log += write_helo
        log += write_mail_from
        log += write_mail_to
        #log += write_subject
        log += write_mail_data
        log += write_quit
      rescue
        puts log
      end
      puts log
    end

    private

    def fix_mails_for_smtp
      opts["from"] = "<#{opts["from"]}>"
      opts["to"] = "<#{opts["to"]}>"
    end

    def open_socket
      @socket = TCPSocket.open(@opts["server"], @opts["port"])
      read_socket(@socket)
    end

    def write_helo
      @socket.puts("HELO #{opts["HELO"]}")
      read_socket(@socket)
    end

    def write_mail_from
      @socket.puts("MAIL from: #{opts["from"]}")
      read_socket(@socket)
    end

    def write_mail_to
      @socket.puts("RCPT to: #{opts["to"]}")
      read_socket(@socket)
    end

    def write_mail_subject

    end

    def write_mail_data
      @socket.puts("DATA\r\n")
      input = read_socket(@socket)
      @socket.puts("#{opts["body"]}\r\n.\r\n")
      input += read_socket(@socket)
    end

    def write_quit
      @socket.puts("QUIT")
      read_socket(@socket)
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

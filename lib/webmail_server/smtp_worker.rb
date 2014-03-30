require 'socket'

module WebMailServer

  class SMTPWorker
    attr_accessor :opts

    def initialize(opts={})
      opts[:server]       ||= WebMailServer::SMTP_SERVER
      opts[:HELO]         ||= "client.smtp.ik2213.lab"
      opts[:from]         ||= 'email@kth.se'
      opts[:to]           ||= 'fvas@kth.se'
      opts[:subject]      ||= "This is the subject"
      opts[:body]         ||= "Watch out in KTH ! "
      opts[:port]         ||= 25
      @opts ||= opts
    end

    def read_socket(socket)
      input = nil
      begin
        input = socket.read_nonblock(5000)
      rescue Errno::EAGAIN
        retry
      end
    end
    #add safety/validation by checking answer OK"
    def send_email
      socket = TCPSocket.open(@opts[:server], @opts[:port])
      input = read_socket(socket)
      puts input
      socket.puts("HELO client.smptp.ik2213.lab")
      input = read_socket(socket)
      puts input
      socket.puts("MAIL from: <sender@kth.se>")
      input = read_socket(socket)
      puts input
      socket.puts("RCPT to: <fvas@kth.se>")
      input = read_socket(socket)
      puts input
      socket.puts("DATA\r\n")
      input = read_socket(socket)
      puts input
      socket.puts("#{opts[:body]}\r\n.\r\n")
      input = read_socket(socket)
      puts input
      socket.puts("QUIT")
      input = read_socket(socket)
      puts input
    end






=begin

    def send_email(opts={})
      opts[:server]       ||= WebMailServer::SMTP_SERVER
      opts[:HELO]         ||= "client.smtp.ik2213.lab"
      opts[:from]         ||= 'email@kth.se'
      opts[:to]           ||= 'fvas@kth.se'
      opts[:subject]      ||= "λαλαλαλα"
      opts[:body]         ||= "λασδασδκαξσδηακσξδηξ δακξσδη ακξσδ "

      msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{opts[:to]}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE
puts opts

      Net::SMTP.start(opts[:server], 25, opts[:HELO]) do |smtp|
        smtp.send_message msg, opts[:from], opts[:to]
      end
    end
=end

  end
end

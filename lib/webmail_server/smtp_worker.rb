module WebMailServer

  class SMTPWorker

    def send_email(opts={})
      opts[:server]       ||= WebMailServer::SMTP_SERVER
      opts[:from]         ||= 'email@kth.se'
      opts[:to]           ||= 'fvas@kth.se'
      opts[:subject]      ||= "You need to see this"
      opts[:body]         ||= "Important stuff!"

      msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

      Net::SMTP.start(opts[:server]) do |smtp|
        smtp.send_message msg, opts[:from], opts[:to]
      end
    end



  end
end

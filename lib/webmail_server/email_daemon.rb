require 'singleton'
require 'uri'
require 'securerandom'

module WebMailServer
  class EmailDaemon
    include Singleton

    attr_reader :emails_array

    def initialize
      @logger = ::Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
      @emails_array = []
      @semaphore = Mutex.new

      Thread.new do
        watch_new_emails
      end
    end

    def add(options)
      random_id = SecureRandom.urlsafe_base64
      options["random_id"] = random_id
      @semaphore.synchronize {
        @emails_array << Email.new(options)
      }
      return random_id
    end

    def watch_new_emails
      while true do
        sleep(1)
        @semaphore.synchronize {
          next if @emails_array.empty?
          @emails_array.sort_by! { |obj| obj.delivery }

          @emails_array.each do |e|
            if Time.now.to_i >= e.delivery && !e.sent
              e.dispatch
              log, error = e.confirmation_email(log(e.options["random_id"]))

              @logger.debug { "============= Confirmation Email Log ==================" }
              @logger.debug { log }
              @logger.debug { "============= Confirmation Email Log ==================" }
            end
          end
        }
      end
    end

    def log(id)
      output = "Email id not found"
      @emails_array.each do |v|
        if v.options["random_id"] == id
          if v.sent
            output = ""
            if v.error
              output += "Mail was not sent!\n Error:  "
              output += v.error + "\n"
              output += "Detailed log\n \n"
            else
              output += "Mail was successfully sent!\n"
              output += "Detailed log\n \n"
            end
            output += v.log
            break
          else
            output = "Email not sent yet\n"
            output += v.log
          end
        end
      end
      return output
    end

    def to_html(id=nil)
      output = ""
      if id
        output = "Email id not found"
        @emails_array.each do |v|
          if v.options["random_id"] == id
            output = v.to_html
            break
          end
        end
      else
        @emails_array.each do |v|
          output += v.to_html
        end
      end

      return output
    end

    private
      class Email
        attr_reader :delay, :delivery, :options, :registered, :delivery, :sent,
          :log, :error
        def initialize(options)
          puts options
          @options = options
          @delay = options["delay"].to_i
          @registered = Time.now.to_i
          @delivery = @registered + @delay.to_i
          @sent = false
          @log = "Log will be available after \n #{Time.at(@delivery)}"
          @error = nil
        end

        def dispatch
          puts "Dispatching email"
          @log, @error = SMTPWorker.new(@options.dup).send_email
          @sent = true
        end

        def confirmation_email(log)
          opts = options.dup
          opts["to"] = opts["from"]
          opts["from"] = "noreply@example.com"
          if @error
            opts["subject"] = "Mail to #{options["to"]} failed"
          else
            opts["subject"] = "Mail to #{options["to"]} successfully sent"
          end
          opts["message"] = log.gsub("\r\n.\r\n","\r\n{dot}\r\n")
          log, error = SMTPWorker.new(opts).send_email
          return [log, error]
        end

        def to_html
          if @error
            time_to_send = "Failed"
          else
            if @delivery < Time.now.to_i
              time_to_send = "sent"
            else
              time_to_send = Time.at(@delivery)
            end
          end

          output = %{ <tr>
                      <td><a href="status?mail=#{options["random_id"]}">#{options["random_id"]}</td>
                      <td>#{options["from"]}</td>
                      <td>#{options["to"]}</td>
                      <td>#{options["subject"]}</td>
                      <td>#{options["message"]}</td>
                      <td>#{options["delay"]}</td>
                      <td>#{time_to_send}</td>
                    </tr>
          }
        end
      end
  end
end

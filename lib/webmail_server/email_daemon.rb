require 'singleton'
require 'uri'
require 'securerandom'

module WebMailServer
  class EmailDaemon
    include Singleton

    attr_reader :emails_array

    def initialize
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
              puts "Sent email"; p e
            end
          end
        }
      end
    end

    def log(id)
      output = "Email id not found"
      @emails_array.each do |v|
        if v.options["random_id"] == id
          output = v.log
          break
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
          :log
        def initialize(options)
          puts options
          @options = options
          @delay = options["delay"].to_i
          @registered = Time.now.to_i
          @delivery = @registered + @delay.to_i
          @sent = false
          @log = "Log will be available after <br> #{Time.at(@delivery)}"
        end

        def dispatch
          puts "Dispatching email"
          @log = SMTPWorker.new(@options.dup).send_email
          @sent = true
        end

        def to_html
          if @delivery < Time.now.to_i
            time_to_send = "sent"
          else
            time_to_send = Time.at(@delivery)
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

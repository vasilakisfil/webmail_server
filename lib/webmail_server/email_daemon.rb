require 'singleton'

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
      @semaphore.synchronize {
        @emails_array << Email.new(options)
      }
    end

    def watch_new_emails
      while true do
        sleep(1)
        @semaphore.synchronize {
          next if @emails_array.empty?
          @emails_array.sort_by! { |obj| obj.delivery }
          @emails_array.each do |e|
            puts e.options
          end
          puts "---------------"
          @emails_array.each do |e|
            if Time.now.to_i >= e.delivery
              e.dispatch
              puts "Deleting element"; p e
              @emails_array.delete(e)
            end
          end
        }
      end
    end

    def to_html
      output = ""
      @emails_array.each do |v|
        output += v.to_html
      end
      return output
    end

    private
      class Email
        attr_reader :delay, :delivery, :options
        def initialize(options)
          puts options
          @options = options
          @delay = options["delay"].to_i
          @delivery = Time.now.to_i + @delay.to_i
        end

        def dispatch
          puts "Dispatching email"
          SMTPWorker.new(@options).send_email
        end

        def to_html
          output = %{ <tr>
                      <td><a href="#">RandomID</td>
                      <td>#{options["from"]}</td>
                      <td>#{options["to"]}</td>
                      <td>#{options["subject"]}</td>
                      <td>#{options["message"]}</td>
                      <td>#{options["delay"]}</td>
                    </tr>
          }
        end
      end
  end
end

require_relative 'lib/webmail_server'
require 'thread'

semaphore = Mutex.new

module WebMailServer
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
  end
end

emails_array = []
Thread.new do
  while true do
    sleep(1)
    semaphore.synchronize {
      emails_array.sort_by! { |obj| obj.delivery }
      emails_array.each do |e|
        puts e.options
      end
      puts "---------------"
      emails_array.each do |e|
        if Time.now.to_i >= e.delivery
          puts "Deleting element"; p e
          emails_array.delete(e)
        end
      end
    }
      #emails_array.delete_at[0]
  end
end

thr = []
10.times do
  thr << Thread.new do
    for i in 0..10
      options = {}
      sleep(Random.new.rand(0..4))
      options[:subject] = "subject#{i}"
      options[:delay] = Random.new.rand(0..100)
      puts "Inserting new email"
      semaphore.synchronize {
        emails_array << WebMailServer::EmailWorker.new(options)
      }
    end
    sleep(1)
  end
end

thr.each do |t|
  t.join
end




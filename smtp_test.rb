require_relative 'lib/webmail_server'
require 'thread'

semaphore = Mutex.new

module WebMailServer
  class EmailWorker
    attr_reader :delay, :registered, :options
    def initialize(options)
      @options = options
      @delay = options[:delay]
      @registered = Time.now.to_i
    end

    def dispatch
      SMTPWorker.new(@options).send_email
    end
  end
end

emails_array = []
Thread.new do
  while true do
    sleep(1)
    semaphore.synchronize {
      emails_array.sort_by! { |obj| obj.options[:delay] }
      emails_array.each do |e|
        puts e.options
      end
      puts "---------------"
      emails_array.each do |e|
        if Time.now.to_i - e.registered >= e.options[:delay]
          puts "Dispatching Email and deleting element"; p e
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




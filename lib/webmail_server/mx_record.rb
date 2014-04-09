require 'net/dns'
#require_relative 'lib/webmail_server'

module MXRecord
  def self.mx_record(uri)
    if uri.include? "@"
      uri = uri.split("@")[-1] if uri.include? "@"

      hash = {}
      packet = Net::DNS::Resolver.start(uri, Net::DNS::MX)

      packet.answer.each do |p|
        hash[p.preference] = p.exchange
      end
      hash = hash.sort
      hash.first[1]
    else
      nil
    end
  end
end

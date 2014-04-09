module Qprintable
  def self.replace_chars_ascii(line, length=70, encoding = 'ascii', inc_C3 = true)
    if !line.ascii_only? || line.include?("=") 
      replaced = ""
      puts "line before #{line}"
      flag = false
      if line[-2..-1] == "=\n"
        till = line.length-3
        flag = true
        puts "yes i striped it"
      else
        till = line.length
      end
      puts "line after #{line[0..till]}"
      line[0..till].each_char do |char|
        byte = char.ord
        if byte.between?(32, 60) || byte.between?(62,126)
          conv = char
        elsif byte == 10
          conv = "\n"
        else
          if encoding == 'ascii'
            if inc_C3 == true
              conv = "=C3=#{convert_enc(char)}"
            else
              conv = "=#{convert_enc(char)}"
            end
          else encoding == 'utf'
            conv = "=#{byte.to_s(16).upcase}"
          end
        end
        puts "#{char} converted to #{conv}"
        if replaced.lines[-1] != nil && replaced.lines[-1].length+conv.length >= length 
          conv = "=\n" + conv
          puts "spliting conv because went over #{replaced + conv}"
        end
        replaced += conv
      end
    else
      puts 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
      replaced = line
    end
    puts "------FINAL------>>\n#{replaced}"
    if flag == true
          replaced += "=\n"
    end
    return replaced
  end
  
  def self.convert_enc(char)
    if !char.ascii_only?
      char.force_encoding(Encoding::ASCII_8BIT)
      final = char[1]
    else
      final = char
    end
    return final.ord.to_s(16).upcase
  end

  def self.big_line(line, length=10)
    partial_line = ''
    if line.length>length 
      while line.length>length
        #puts "slicing at #{line.slice(0..length)}"
        partial_line += (line.slice(0..length-1) + "=" + "\n")
        line = line.slice!((length)..line.length)
      end 
      partial_line += (line.slice(0..length))
    else
      partial_line = line
    end
    return partial_line 
  end

  def self.additionalreq(line)
    line.gsub!(" \n", "=C3=20\n")
    line.gsub!("\t\n", "=C3=09\n")
    if line[-1].ord == 9 || line[-1].ord == 32
      line += "="
    end
    return line
  end

  def self.sanitize(message, length = 70, encoding='ascii', inc_C3=true)
    sanitized = ''
    message.lines do |line|
      sanitized += big_line(line, length) 
    end
    tmp = ''
    sanitized.lines do |sline|
      tmp += replace_chars_ascii(sline,length, encoding, inc_C3)
    end  
    sanitized = additionalreq(tmp)
    puts "this is sanitized #{sanitized}"
    return sanitized
  end

end

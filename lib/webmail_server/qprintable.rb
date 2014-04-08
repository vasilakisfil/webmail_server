module Qprintable
  def self.replace_chars_ascii(line, encoding = 'ascii', inc_C3 = true)
    if !line.ascii_only? 
      result = line.each_char.collect do |char|
        byte = char.ord
        puts "this is the byte #{byte}"
        if byte.between?(32, 60) || byte.between?(62,126)
          byte.chr
        elsif byte == 10
          "\n\r"
        else
          if encoding == 'ascii'
            if inc_C3 == true
              "=C3=#{convert_enc(char)}"
            else
              "=#{convert_enc(char)}"
            end
          else encoding == 'utf'
            "=#{byte.to_s(16).upcase}"
          end
        end
      end
      line = result.join
    end
    return line
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

  def self.replace_chars_utf(line)
    if !line.ascii_only?
      result = line.each_codepoint.collect do |cpoint|
        if cpoint.between?(32, 60) || cpoint.between?(62, 126)
          cpoint.chr
        else
          "=#{cpoint.to_s(16)}"
        end
      end
    else
      return line
    end
    return result.join
  end


  def self.big_line(line, length=72)
    partial_line = '' 
    begin
      puts "slicing at #{line.slice(0..length)}"
      partial_line += (line.slice(0..length) + "=" + "\n\r")
      line = line.slice!((length + 1)..line.length)
    end while line.length>length
    partial_line += (line.slice(0..length) + "=" + "\n\r")
    return partial_line 
  end

  def self.additionalreq(line)
    line.gsub(" \n", " =\n")
    line.gsub("\t\n", "\t=\n")
  end

  def self.sanitize(message, encoding='ascii', inc_C3=true)
    sanitized = ''
    message.lines do |line|
      puts "this is a line #{line}"
      tmp = replace_chars_ascii(line, encoding)
      puts "this is tmp #{tmp}"
      tmp = additionalreq(tmp)
      puts "the additional requirements are taken care in #{tmp}"
      sanitized += big_line(tmp)      
      puts "this is sanitized #{sanitized}"
    end  
    puts "this is sanitized #{sanitized}"
    return sanitized
  end

end

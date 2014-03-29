module WebMailServer
  # Class that holds an HTTP response
  # Follows HTTP protocol naming
  class Response
    STATUS_CODE = { 100 => "Continue", 101 => "Switching Protocols",
    102 => "Processing", 200 => "OK", 201 => "Created", 202 => "Accepted",
    203 => "Non-Authoritative Information", 204 => "No Content",
    205 => "Reset Content", 206 => "Partial Content", 207 => "Multi-Status",
    208 => "IM Used", 300 => "Multiple Choices", 301 => "Moved Permanently",
    302 => "Found", 303 => "See Other", 304 => "Not Modified",
    305 => "Use Proxy", 306 => "Switch Proxy", 307 => "Temporary Redirect",
    308 => "Permanent Redirect", 400 => "Bad Request", 401 => "Unauthorized",
    402 => "Payment Required", 403 => "Forbidden", 404 => "Not Found",
    405 => "Method Not Allowed", 406 => "Not Acceptable",
    407 => "Proxy Authentication Required", 408 => "Request Timeout",
    409 => "Conflict", 410 => "Gone", 411 => "Length Required",
    412 => "Precondition Failed", 413 => "Request Entity Too Large",
    415 => "Unsupported Media Type", 416 => "Requested Range Not Satisfiable",
    417 => "Expectation Failed", 419 => "Authentication Timeout",
    420 => "Enhance Your Calm", 426 => "Upgrade Required",
    428 => "Precondition Required", 429 => "Too Many Requests",
    451 => "Unavailable For Legal Reasons", 500 => "Internal Server Error",
    501 => "Not Implemented", 502 => "Bad Gateway", 503 => "Service Unavailable",
    504 => "Gateway Timeout", 505 => "HTTP Version Not Supported" }

    attr_accessor :status_line, :http_version, :status_code, :header_field,
      :body

    # Initializes the most basic fields of the HTTP response
    # (Any field can be re-configured through header_field method)
    def initialize(request)
      @request = request
      create_headers
      create_body
    end

    def create_headers
      current_time = Time.new.utc.strftime("%a, %d %b %Y %H:%M:%S")
      @http_version = "HTTP/1.1"
      @header_field = Hash.new
      @header_field[:'Access-Control-Origin'] = "*"
      @header_field[:'Accept-Ranges'] = "bytes"
      @header_field[:Age] = "0"
      @header_field[:Allow] = "GET"
      @header_field[:'Cache-Control'] = "private, max-age=0"
      @header_field[:Connection] = ""
      # fix that
      @header_field[:'Content-Encoding'] = ""
      @header_field[:'Content-Language'] = "en"
      # fix that
      @header_field[:'Content-Length'] = ""
      # fix that
      @header_field[:'Content-MD5'] = ""
      @header_field[:'Content-Disposition'] = ""
      @header_field[:'Content-Range'] = ""
      @header_field[:'Content-Type'] = "text/html; charset=utf-8"
      @header_field[:Date] = "#{current_time} GMT"
      @header_field[:ETag] = ""
      @header_field[:Expires] = "-1"
      @header_field[:'Last-Mmodified'] = "#{current_time} GMT"
      @header_field[:Link] = ""
      @header_field[:Location] = ""
      @header_field[:P3P] = ""
      @header_field[:Pragma] = ""
      @header_field[:'Proxy-Authenticate'] = ""
      @header_field[:Refresh] = ""
      @header_field[:'Retry-After'] = "60"
      @header_field[:Server] = "GoatServer 0.0001 (Unix)"
      @header_field[:'Set-Cookie'] = ""
      @header_field[:Status] = @status_code =  "200"
      @header_field[:'Strict-Transport-Security'] = ""
      @header_field[:Trailer] = ""
      @header_field[:'Transfer-Encoding'] = ""
      @header_field[:Vary] = ""
      @header_field[:Via] = ""
      @header_field[:Warning] = ""
      @header_field[:'WWW-Authenticate'] = ""
      @status_line = "#{@http_version} #{@status_code} #{STATUS_CODE[@status_code.to_i]}"
    end


    def create_body
      puts @request.request_uri
      puts @request.method
      if @request.request_uri == "/index" && @request.method == "GET"
        create_index_body
      elsif @request.request_uri == "/send_mail" && @request.method == "POST"
        create_sent_mail_body
      else
        create_default_body
      end
    end

    def create_index_body
      filepath = "#{WebMailServer::SERVER_ROOT}index.html"
      puts filepath
      file = File.open filepath
      self.body = HTTPBody.new(file.read).to_s
      self.header_field[:'Content-Type'] = "text/html; charset=utf-8"
      file.close
    end

    def create_sent_mail_body
      filepath = "#{WebMailServer::SERVER_ROOT}sent_mail.html"
      file = File.open filepath
      self.body = HTTPBody.new(file.read)
      self.header_field[:'Content-Type'] = "text/html; charset=utf-8"
      file.close
    end

    def create_default_body
      filepath = "#{WebMailServer::SERVER_ROOT}#{@request.request_uri}"
      if File.exists? filepath
        case @request.request_uri
        when /\.(?:html)$/i
          file = File.open filepath
          self.body = Body.new file.read
          self.header_field[:'Content-Type'] = "text/html; charset=utf-8"
          file.close
        when /\.(?:css)$/i
          file = File.open filepath
          self.body = Body.new file.read
          self.header_field[:'Content-Type'] = "text/css"
          file.close
        when /\.(?:js)$/i
          file = File.open filepath
          self.body = Body.new file.read
          self.header_field[:'Content-Type'] = "text/javascript"
          file.close
        when /\.(?:jpg)$/i
          file = File.open(filepath, "rb")
          self.body = Body.new file.read
          self.header_field[:'Accept-Ranges'] = "bytes"
          self.header_field[:'Content-Type'] = "image/jpeg"
          file.close
        when /\.(?:png)$/i
          file = File.open(filepath, "rb")
          self.body = Body.new file.read
          self.header_field[:'Accept-Ranges'] = "bytes"
          self.header_field[:'Content-Type'] = "image/png"
          file.close
        else
          self.body = Body.new "Wrong file!"
        end
      else
        self.body = Body.new "Could not find file!"
      end
    end

    def header_fields
      @header_fields = ""
      @header_field.each do |field, value|
        @header_fields += "#{field}: #{value}\n" if !value.empty?
      end
      return @header_fields
    end

    # Returns a string version of the HTTP response
    def to_s
      response = "#{@status_line}\n#{@header_fields}\n#{@body}"
    end

    private

    class HTTPBody
      attr_accessor :html_document, :html_header, :html_body

      def initialize(html_input)
        @html_document = html_input
        parse_html_page
      end

      def parse_html_page
        @html_header = Element.new(@html_document, "<head>", "</head>")
        @html_body = Element.new(@html_document, "<body>", "</body>")
      end

      def to_s
        @html_document
      end

      private

      class Element
        attr_reader :range, :element, :content
        def initialize(document, element1, element2)
          @element = [element1, element2]
          start_position = document.index(element1) + 6
          end_position = document.index(element2)
          @range = Range.new(start_position, end_position)
          @content = document[@range]
        end
      end
    end


  end
end

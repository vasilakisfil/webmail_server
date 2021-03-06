require 'spec_helper'
require 'tempfile'
require 'rest-client'

describe WebMailServer::Request do
  before(:all) do
    good_req_str = "GET /index.html HTTP/1.1\n"
    good_req_str += "Host: www.example.com\r\n"
    @good_req = WebMailServer::Request.new(good_req_str)

    bad_req_str_meth = "MEH /index.html HTTP/1.1\n"
    bad_req_str_meth += "Host: www.example.com\r\n"
    @bad_req = WebMailServer::Request.new(bad_req_str_meth)
  end

  context "with valid data" do
    it "splits them accordingly" do
      expect(@good_req.method).to eq('GET')
      expect(@good_req.request_uri).to eq('/index.html')
      expect(@good_req.valid?).to be_true
    end
  end

  context "with invalid data" do
    it "returns false #valid?" do
      expect(@bad_req.valid?).to be_false
    end
  end
end

describe WebMailServer::Response do
  before(:all) do
   @response = WebMailServer::Response.new
  end

  it " basic fields initialized correctly" do
    expect(@response.status_line).to  eq("HTTP/1.1 200 OK")
    expect(@response.header_field[:Server]).to include("GoatServer")
  end
end



describe WebMailServer::HTTPServer do

  before(:all) do
    @server_root = "#{Dir.getwd}/spec/server_assets"
    @port = 5555
    @server = WebMailServer::HTTPServer.new(@port)
  end

  after(:all) do
    @server = nil
  end

  context "with full initializer" do

    it "sets the right conf file and port" do
      expect(@server.server_root).to eq(@server_root)
      expect(@server.port).to eq(@port)
    end
  end

  context "Requesting a page by GET" do
    it "shows the html code" do
      htmlFile = "index.html"
      link = "http://localhost:#{@port}/#{htmlFile}"
      response = RestClient.get link
      expect(response.to_str).to eq(File.open("#{@server_root}/#{htmlFile}").read)
    end

  end
end

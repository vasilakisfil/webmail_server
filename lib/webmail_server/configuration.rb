module WebMailServer
  ROOT_DIR = "#{File.expand_path(File.dirname(__FILE__))}/../assets"
  ERROR_404_PAGE = "#{ROOT_DIR}/404.html"
  DEFAULT_PAGE = "#{ROOT_DIR}/default.html"

  SMTP_SERVER = "smtp.ik2213.lab"
end

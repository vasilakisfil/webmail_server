#WebMail Server

A very simple web mail server written in ruby.

Before trying to run the server, Ruby needs to be installed on the system. An easy way to achieve that is by using the RVM - Ruby Version Manager tool found at https://rvm.io/

Once Ruby is installed, in order to run the server the following commands can be used:

```
bundle install #installs necessary libs
ruby server.rb
```
Then go to [http://localhost:5555/index](http://localhost:5555/index) and you should see the form.

##More info
The code includes a fully functioned HTTP server, an SMTP client, a DNS lookup utility for the MX records, all together loosly coupled with the main core functionality: a form to send the email, a general status page and a per email status page. It is nice to see how you edit on the fly the HTTP response to deliver dynamically content on the client. There is support for Swedish characters too according to RFC2047.


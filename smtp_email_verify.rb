require 'resolv'
require 'net/telnet'
require 'net/smtp'

class SmtpEmailVerify

  NAME_SERVERS = ['8.8.8.8', '8.8.4.4']
  attr_accessor :dns_resolver, :email, :domain, :mx_resource, :valid

  def initialize email, domain
    @email = email
    @domain = Resolv::DNS::Name.create(domain)

    begin
      dns_resolver(@domain.to_s)
    rescue Resolv::ResolvError
      raise "Invalid Domain"
    end

    validate_email!
    
  end

  def valid?
    @valid
  end

  # An attempt to use telnet instead of smtp
  def _validate_email!
    raise "Please set HELO_DOMAIN and MAIL_FROM" unless defined?(HELO_DOMAIN) && defined?(MAIL_FROM)

    smtp = Net::Telnet::new("Host" => mx_domain.to_s,"Port" => 25, "Telnetmode" => true, "Prompt" => /(^250)(OK)/i)
    # 
    smtp.cmd("String" => "HELO #{HELO_DOMAIN}", "Match" => /\n/) {|c| print c }
    smtp.cmd("MAIL FROM: <#{MAIL_FROM}>"){|c| print c}
    smtp.cmd("RCPT TO: <#{@email}>"){|c| 
      @valid =  (c =~ /ok/i  ? true : false)
    }
    smtp.close
  
  end
  
  def mx_domain
    @mx_resource.exchange
  end

  def dns_resolver domain
    @dns_resolver = Resolv::DNS.new(:nameserver => NAME_SERVERS, :search => [domain.to_s], :ndots => 1)
    @mx_resource = @dns_resolver.getresource(domain,Resolv::DNS::Resource::IN::MX)
  end


  def self.set_helo helo, mailfrom
    self.const_set(:HELO_DOMAIN , helo)
    self.const_set(:MAIL_FROM, mailfrom)
  end

  def self.verify email

    domain = email.split("@").last

    new(email,domain)
  end
end

require_relative 'smtp_email_verify.rb'

email_address = ARGV.shift

# Tell smtp servers who we are
SmtpEmailVerify.set_helo "example.com", "check@example.com"

email = SmtpEmailVerify.verify(email_address)
puts "#{email_address} : VALID: #{email.valid?}"

#
# WEBHOOK
#
namespace :makati do
  desc "Set webhook for a given token."
  task :set_webhook do |t, args|
    # Server.check(verbose:false)
    # certificate = Server.certificate_file_pem
    Webhook.set
  end
end

# FooError = Class.new(StandardError)

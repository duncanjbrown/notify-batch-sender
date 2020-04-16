require 'notifications/client'
require 'csv'

api_key = "XXX"
notify_template_id = "5412a168-0411-478e-bdb0-bb3a4fde1e32"
csv_path, pdf_path = ARGV
pdf_handle = StringIO.new(File.read(pdf_path))
client = Notifications::Client.new(api_key)

puts "This will send the Notify email template #{notify_template_id} to the emails in #{csv_path} attaching #{pdf_path}"

def csv_to_hashes(csv)
  CSV.read(csv, headers: true).map do |row|
    h = row.to_h
    h.keys.zip(h.values.map(&:strip)).to_h
  end
end

def send_email(client, template, address, name, pdf_handle)
  pdf_handle.rewind
  client.send_email(
    email_address: address,
    template_id: template,
    personalisation: {
      name: name,
      link_to_attachment: Notifications.prepare_upload(pdf_handle),
    }
  )
end

def actually_email_providers!(client, user_hashes, template, pdf_handle)
  user_hashes.each do |h|
    puts h.inspect
    send_email(client, template, h["Email address"], h["Name"], pdf_handle)
  end
end

=begin
actually_email_providers!(
  client,
  [{"Name" => "Colleague", "Email address" => "duncan.brown@digital.education.gov.uk"}],
  notify_template_id,
  pdf_handle
)
=end

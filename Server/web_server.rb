require 'webrick'
require 'socket'

def public_ipv4
  Socket.ip_address_list.select { |intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? }.map { |ipv| ipv.ip_address }.uniq
end

thread = Thread.new do
  host = ARGV && ARGV[0] ? ARGV[0] : public_ipv4.uniq[0]
  port = 8081
  puts "Starting local server on #{host}:#{port}"
  web_server = WEBrick::HTTPServer.new(
      :BindAddress => host,
      :Port => port,
      :DocumentRoot => 'docs',
      :ServerType => WEBrick::SimpleServer
  )
  web_server.mount_proc '/download' do |req, response|
    path = File.join(File.dirname(__FILE__), 'docs', 'app_one.zip')
    response.body = File.open(path, 'rb')
    response['content-type'] = 'application/zip'
    response.status = 200
  end

  web_server.start
end

thread.join



require 'sequel'
require 'uri'

url = ENV['DATABASE_URL']
if url.nil? || url.empty?
  raise 'DATABASE_URL is required in production' if ENV['RACK_ENV'] == 'production'
  url = 'postgres://localhost/bnb_development'
end
options = { max_connections: ENV['RACK_ENV'] == 'test' ? 1 : 5 }
if RUBY_ENGINE == 'jruby' && /\Apostgres(?:ql)?:/.match?(url)
  parsed = URI.parse(url)
  host = parsed.host.include?(':') ? "[#{parsed.host}]" : parsed.host
  jdbc_url = "jdbc:postgresql://#{host}:#{parsed.port || 5432}#{parsed.path}"
  jdbc_url += "?#{parsed.query}" if parsed.query
  options[:user] = URI.decode_www_form_component(parsed.user) if parsed.user
  options[:password] = URI.decode_www_form_component(parsed.password) if parsed.password
  url = jdbc_url
end
DB = Sequel.connect(url, **options)

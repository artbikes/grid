require 'sinatra'

class Application < Sinatra::Base

	if ENV['VCAP_SERVICES'].nil?
     DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/words.db")
   else
     require 'json'
     svcs = JSON.parse ENV['VCAP_SERVICES']
     mysql = svcs.detect { |k,v| k =~ /^mysql/ }.last.first
     creds = mysql['credentials']
     user, pass, host, name = %w(user password host name).map { |key| creds[key] }
     DataMapper.setup(:default, "mysql://#{user}:#{pass}@#{host}/#{name}")
   end


	class Wordtype
		include DataMapper::Resource
		property :id,		Serial
		property :word,		String
	end
	DataMapper.finalize
	DataMapper.auto_upgrade!
	class DbSeeds
		def self.seed
			DO IT
		end
	end
	get '/' do
		haml :'index'
	end
end


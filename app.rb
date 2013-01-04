require 'sinatra'



class Application < Sinatra::Base
	class Wordtype
		property :id,		Serial
		property :word,		String
	end
	DataMapper.finalize
	Word.auto_upgrade!
	class DbSeeds
		def self.seed
			DO IT
		end
	end
	get '/' do
		haml :'index'
	end
end


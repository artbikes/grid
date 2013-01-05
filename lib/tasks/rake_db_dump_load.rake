#largely based on http://devblog.michaelgalero.com/2008/11/03/custom-rake-tasks-in-merb-data-import/

require 'rake'

ENV['ENVIRONMENT'] = 'test' if ENV['ENVIRONMENT'].nil?

# DB tasks
namespace :db do
  require 'dm-core'
  require 'dm-types'
  require 'dm-timestamps'
  require 'dm-constraints'
  require 'dm-validations'
  require 'dm-migrations'
  require 'dm-serializer'
  
  desc "Dump data from the current environment's DB."
  task :dump_data do
    #NOTE: Decimals in your models do not dump!!! I changed mine to Float for this purpose
    dir = "#{File.dirname(__FILE__)}/dev/db" #Change to suit
    FileUtils.mkdir_p(dir)
    FileUtils.chdir(dir)
    boot_repository
    DataMapper::Model.descendants.entries.each do |table|
      puts "Dumping #{table}..."
      File.open("#{table}.yml", 'w+') { |f| f.print table.all.to_yaml }
    end
  end

  desc "Load data (from spec/db/*.yml) into the current environment's DB."
  task :load_data do
    # Alternatively, dm-yaml-adapter can use the dumped files directly:
    #  This is slower than sqlite::memory: (obv) but faster than MySQL (for me...)
    #  DataMapper.setup(:default, {:adapter => 'yaml', :path => 'spec/db'})
    dir = "#{File.dirname(__FILE__)}/spec/db" #Change to suit
    FileUtils.mkdir_p(dir)
    FileUtils.chdir(dir)
    boot_repository
    DataMapper::Model.descendants.entries.each do |table|
      puts "Loading #{table} data..."
      YAML.load_file("#{table}.yml").each do |fixture|
        table.create( fixture )
      end
    end
  end
  
  def boot_repository
    case ENV['ENVIRONMENT']
    when 'prod'
      p '! -- PROD ENVIRONMENT not configured!!!'
    when 'dev'
      DataMapper.setup(:default, 'mysql://user:password@localhost/dev_db')
      Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |model| require model }
      DataMapper.finalize if DataMapper.respond_to?(:finalize)
      DataMapper.auto_upgrade! # Safely applies any migrations it can
    else # test is the default case
      DataMapper.setup(:default, 'sqlite::memory:')
      Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |model| require model }
      DataMapper.finalize if DataMapper.respond_to?(:finalize)
      DataMapper.auto_migrate! # Destructively recreates all tables and indexes
    end
  end
end
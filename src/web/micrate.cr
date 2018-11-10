require "micrate"
require "pg"

require "./app/config"

config = SGM::Web.config.from_file("config.yml")
Micrate::DB.connection_url = config.database_url

def Micrate.migrations_dir
  "db"
end

def Micrate.migrations_by_version
  Dir.entries(migrations_dir)
    .select { |name| File.file? File.join("db", name) }
    .select { |name| /^\d+_.+\.sql$/ =~ name }
    .map { |name| Migration.from_file(name) }
    .index_by { |migration| migration.version }
end

Micrate::Cli.run

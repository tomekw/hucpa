# Hucpa

A JRuby wrapper to [HikariCP](https://github.com/brettwooldridge/HikariCP) - "zero-overhead" production ready JDBC connection pool.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hucpa"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hucpa

## Usage

Install the database driver, for PostgreSQL:

```ruby
gem "jdbc-postgres"
```

Load the the database driver if needed, for PostgreSQL:

```ruby
require "jdbc/postgres"
Jdbc::Postgres.load_driver
```

Configure the connection pool:

```ruby
options = {
  adapter: :postgresql,
  database_name: "hucpa",
  password: "hucpa",
  server_name: "postgres",
  username: "hucpa"
}

connection_pool = Hucpa::ConnectionPool.new(options)

datasource = connection_pool.open

connection = datasource.connection

result_set =
  connection
    .create_statement
    .execute_query("SELECT 42 AS answer")

answer = (result_set.next and result_set.get_int("answer"))

puts answer
;; 42

connection.close

connection_pool.close
```

## Development

TODO: Write development instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomekw/hucpa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

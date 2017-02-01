# Hucpa

[![Code Climate](https://codeclimate.com/github/tomekw/hucpa/badges/gpa.svg)](https://codeclimate.com/github/tomekw/hucpa) [![Gem Version](https://badge.fury.io/rb/hucpa.svg)](https://badge.fury.io/rb/hucpa) [![CircleCI](https://circleci.com/gh/tomekw/hucpa.svg?style=svg)](https://circleci.com/gh/tomekw/hucpa)

A JRuby wrapper to [HikariCP](https://github.com/brettwooldridge/HikariCP) - "zero-overhead" production ready JDBC connection pool.
This is / will be a part of a bigger effort, like a dedicated library to use SQL and / or ActiveRecord integration.

Please note the project support only JRuby (tested with 9.1.7.0+) on Java 8.

The public API is subject to change before version `1.0.0`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "hucpa"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hucpa

## Configuration options

See [HikariCP Documentation](https://github.com/brettwooldridge/HikariCP#configuration-knobs-baby) for a detailed description.
Not all HikariCP-defined configuration options are currently supported. To add support for infrequently used options please
raise an issue or file a pull request.

| Option                  | Required | Default value | Notes                                                                   |
| ----------------------- | :------: | ------------- | ----------------------------------------------------------------------- |
| `adapter`               | Yes(1)   | -             | Symbol                                                                  |
| `auto_commit`           | No       | `true`        | Boolean                                                                 |
| `connection_test_query` | No       | -             | String                                                                  |
| `connection_timeout`    | No       | `30_000`      | Integer, greater than or equal to 250, in miliseconds                   |
| `database_name`         | No       | -             | String                                                                  |
| `idle_timeout`          | No       | `600_000`     | Integer, 0 (disabled) or greater than or equal to 10000, in miliseconds |
| `jdbc_url`              | Yes(1)   | -             | String                                                                  |
| `max_lifetime`          | No       | `1_800_000`   | Integer, 0 (disabled) or greater than or equal to 30000, in miliseconds |
| `maximum_pool_size`     | No       | `10`          | Integer, greater than or equal to 1                                     |
| `minimum_idle`          | No       | `10`          | Integer, greater than or equal to 1                                     |
| `password`              | Yes      | -             | String                                                                  |
| `pool_name`             | No       | -             | String                                                                  |
| `server_name`           | No       | -             | String                                                                  |
| `username`              | Yes      | -             | String                                                                  |

`(1)` - either `adapter` or `jdbc_url` has to be provided.

## Supported adapters and corresponding datasource class names

| Adapter          | Datasource class name                              |
| ---------------- | -------------------------------------------------- |
| `db2`            | `com.ibm.db2.jcc.DB2SimpleDataSource`              |
| `derby`          | `org.apache.derby.jdbc.ClientDataSource`           |
| `fdbsql`         | `com.foundationdb.sql.jdbc.ds.FDBSimpleDataSource` |
| `firebird`       | `org.firebirdsql.pool.FBSimpleDataSource`          |
| `h2`             | `org.h2.jdbcx.JdbcDataSource`                      |
| `hsqldb`         | `org.hsqldb.jdbc.JDBCDataSource`                   |
| `mariadb`        | `org.mariadb.jdbc.MySQLDataSource`                 |
| `mysql`          | `com.mysql.jdbc.jdbc2.optional.MysqlDataSource`    |
| `oracle`         | `oracle.jdbc.pool.OracleDataSource`                |
| `pgjdbc_ng`      | `com.impossibl.postgres.jdbc.PGDataSource`         |
| `postgresql`     | `org.postgresql.ds.PGSimpleDataSource`             |
| `sqlite`         | `org.sqlite.JDBC`                                  |
| `sqlserver_jtds` | `net.sourceforge.jtds.jdbcx.JtdsDataSource`        |
| `sqlserver`      | `com.microsoft.sqlserver.jdbc.SQLServerDataSource` |
| `sybase`         | `com.sybase.jdbcx.SybDataSource`                   |

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
# Using the adapter option
options = {
  adapter: :postgresql,
  database_name: "hucpa",
  password: "hucpa",
  server_name: "postgres",
  username: "hucpa"
}

# Using the jdbc_url option
options = {
  jdbc_url: "jdbc:postgresql://postgres/hucpa",
  password: "hucpa",
  username: "hucpa"
}

connection_pool = Hucpa::ConnectionPool.new(options)
```

Use the connection pool with the `with_connection` API:


```ruby
answer = connection_pool.with_connection do |connection|
  result_set =
    connection
      .create_statement
      .execute_query("SELECT 42 AS answer")

  result_set.next and result_set.get_int("answer")
end

answer
=> 42
```

Or use the connection pool with the "classic" API:

```ruby
datasource = connection_pool.open

# Explicitly obtain the DB connection
connection = datasource.connection

result_set =
  connection
    .create_statement
    .execute_query("SELECT 42 AS answer")

answer = result_set.next and result_set.get_int("answer")

# Explicitly release the DB connection
connection.close

answer
=> 42
```

Close the connection pool:

```ruby
connection_pool.close

```

## Development

Build the Docker image:

    $ docker-compose build

Create services:

    $ docker-compose create

Run specs:

    $ docker-compose run --rm app rspec spec

Run console:

    $ docker-compose run --rm app irb

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tomekw/hucpa. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

require "spec_helper"

RSpec.describe Hucpa::ConnectionPool do
  subject(:connection_pool) { described_class.new(options) }

  let(:database_host) { ENV.fetch("DATABASE_HOST", "postgres") }

  before(:all) do
    require "jdbc/postgres"
    Jdbc::Postgres.load_driver
  end

  context "when valid adapter options provided" do
    let(:options) do
      {
        adapter: :postgresql,
        database_name: "hucpa",
        password: "hucpa",
        server_name: database_host,
        username: "hucpa"
      }
    end

    let(:expected_answer) { 42 }

    it "returns the Answer to the Ultimate Question of Life, the Universe, and Everything" do
      answer = connection_pool.with_connection do |connection|
        result_set = connection.create_statement.execute_query("SELECT 42 AS answer")

        result_set.next and result_set.get_int("answer")
      end

      expect(answer).to eq expected_answer

      connection_pool.close
    end
  end

  context "when valid jdbc_url options provided" do
    let(:options) do
      {
        jdbc_url: "jdbc:postgresql://#{database_host}/hucpa",
        password: "hucpa",
        username: "hucpa"
      }
    end

    let(:expected_answer) { 42 }

    it "returns the Answer to the Ultimate Question of Life, the Universe, and Everything" do
      answer = connection_pool.with_connection do |connection|
        result_set = connection.create_statement.execute_query("SELECT 42 AS answer")

        result_set.next and result_set.get_int("answer")
      end

      expect(answer).to eq expected_answer

      connection_pool.close
    end
  end
end

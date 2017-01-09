require "spec_helper"

RSpec.describe Hucpa::ConnectionPool do
  subject(:connection_pool) { described_class.new(options) }

  before(:all) do
    require "jdbc/postgres"
    Jdbc::Postgres.load_driver
  end

  context "when valid options provided" do
    let(:options) do
      {
        adapter: :postgresql,
        database_name: "hucpa",
        password: "hucpa",
        server_name: "postgres",
        username: "hucpa"
      }
    end

    let(:expected_answer) { 42 }

    it "returns the Answer to the Ultimate Question of Life, the Universe, and Everything" do
      datasource = connection_pool.open

      connection = datasource.connection

      result_set =
        connection
          .create_statement
          .execute_query("SELECT 42 AS answer")

      answer = (result_set.next and result_set.get_int("answer"))

      expect(answer).to eq expected_answer

      connection.close

      connection_pool.close
    end
  end
end

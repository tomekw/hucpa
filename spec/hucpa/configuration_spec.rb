require "spec_helper"

describe Hucpa::Configuration do
  subject(:config) { described_class.new(options) }

  let(:required_options) do
    {
      adapter: :postgresql,
      password: "hucpa",
      username: "hucpa"
    }
  end

  let(:all_valid_options) do
    required_options.merge(
      database_name: "hucpa",
      server_name: "postgres"
    )
  end

  context "when all valid options provided" do
    let(:options) { all_valid_options }

    it "doesn't raise error" do
      expect do
        config.to_hikari_config
      end.not_to raise_error
    end
  end

  context "when only required options provided" do
    let(:options) { required_options }

    it "doesn't raise error" do
      expect do
        config.to_hikari_config
      end.not_to raise_error
    end
  end

  context "when adapter not provided" do
    let(:options) { required_options.select { |k, _| k != :adapter } }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "adapter is missing, adapter must be one of: derby, firebird, db2, h2, hsqldb, mariadb, mysql, sqlserver_jtds, sqlserver, oracle, pgjdbc_ng, postgresql, fdbsql, sybase, sqlite")
    end
  end

  context "when adapter invalid" do
    let(:options) { required_options.merge(adapter: :unknown_adapter) }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "adapter must be one of: derby, firebird, db2, h2, hsqldb, mariadb, mysql, sqlserver_jtds, sqlserver, oracle, pgjdbc_ng, postgresql, fdbsql, sybase, sqlite")
    end
  end
end

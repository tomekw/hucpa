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
      end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url has to be provided")
    end
  end

  context "when adapter invalid" do
    let(:options) { required_options.merge(adapter: :unknown_adapter) }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "adapter must be one of: db2, derby, fdbsql, firebird, h2, hsqldb, mariadb, mysql, oracle, pgjdbc_ng, postgresql, sqlite, sqlserver, sqlserver_jtds, sybase")
    end
  end

  context "when jdbc_url provided instead of adapter" do
    let(:options) do
      {
        jdbc_url: "jdbc:postgresql://postgres/hucpa",
        password: "hucpa",
        username: "hucpa"
      }
    end

    it "doesn't raise error" do
      expect do
        config.to_hikari_config
      end.not_to raise_error
    end
  end

  context "when both adapter and jdbc_url provided" do
    let(:options) do
      required_options.merge(jdbc_url: "jdbc:postgresql://postgres/hucpa")
    end

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url has to be provided")
    end
  end
end

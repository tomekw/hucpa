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
      auto_commit: false,
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

    it "sets auto_commit" do
      expect(config.to_hikari_config.auto_commit).to eq false
    end
  end

  context "when only required options provided" do
    let(:options) { required_options }

    it "doesn't raise error" do
      expect do
        config.to_hikari_config
      end.not_to raise_error
    end

    it "is auto-commited by default" do
      expect(config.to_hikari_config.auto_commit).to eq true
    end
  end

  context "when database_name empty" do
    let(:options) { required_options.merge(database_name: "") }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "database_name must be filled")
    end
  end

  context "when server_name empty" do
    let(:options) { required_options.merge(server_name: "") }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "server_name must be filled")
    end
  end

  context "when adapter not provided" do
    let(:options) { required_options.select { |k, _| k != :adapter } }

    it "raises error" do
      expect do
        config.to_hikari_config
      end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url must be filled")
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
      end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url must be filled")
    end
  end
end

require "spec_helper"

describe Hucpa::Configuration do
  subject(:hikari_config) { described_class.new(options).to_hikari_config }

  let(:minimal_options) do
    {
      adapter: :postgresql,
      password: "hucpa",
      username: "hucpa"
    }
  end

  describe "minimal option set" do
    let(:options) { minimal_options }

    context "when adapter configured" do
      it "is valid" do
        expect { hikari_config }.not_to raise_error
      end
    end

    context "when jdbc_url configured" do
      let(:options) { minimal_options.select { |k, _| k != :adapter }.merge(jdbc_url: "jdbc:postgresql://postgres/hucpa") }

      it "is valid" do
        expect { hikari_config }.not_to raise_error
      end
    end
  end

  describe "adapter" do
    context "when not provided" do
      let(:options) { minimal_options.reject { |k, _| k == :adapter } }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url must be filled")
      end
    end

    context "when unknown" do
      let(:options) { minimal_options.merge(adapter: :unknown) }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "adapter must be one of: db2, derby, fdbsql, firebird, h2, hsqldb, mariadb, mysql, oracle, pgjdbc_ng, postgresql, sqlite, sqlserver, sqlserver_jtds, sybase")
      end
    end
  end

  describe "auto_commit" do
    context "when not provided" do
      let(:options) { minimal_options.reject { |k, _| k == :auto_commit } }

      it "is set to true" do
        expect(hikari_config.auto_commit).to eq true
      end
    end

    context "when not boolean" do
      let(:options) { minimal_options.merge(auto_commit: 1) }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "auto_commit must be boolean")
      end
    end

    context "when valid provided" do
      let(:options) { minimal_options.merge(auto_commit: false) }

      it "is set" do
        expect(hikari_config.auto_commit).to eq false
      end
    end
  end

  describe "connection_timeout" do
    context "when not provided" do
      let(:options) { minimal_options.reject { |k, _| k == :connection_timeout } }

      it "is set to 30_000 ms" do
        expect(hikari_config.connection_timeout).to eq 30_000
      end
    end

    context "when too small" do
      let(:options) { minimal_options.merge(connection_timeout: 249) }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "connection_timeout must be greater than or equal to 250")
      end
    end

    context "when valid provided" do
      let(:options) { minimal_options.merge(connection_timeout: 250) }

      it "is set" do
        expect(hikari_config.connection_timeout).to eq 250
      end
    end
  end

  describe "database_name" do
    context "when empty" do
      let(:options) { minimal_options.merge(database_name: "") }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "database_name must be filled")
      end
    end
  end

  describe "idle_timeout" do
    context "when not provided" do
      let(:options) { minimal_options.reject { |k, _| k == :idle_timeout } }

      it "is set to 600_000 ms" do
        expect(hikari_config.idle_timeout).to eq 600_000
      end
    end

    context "when too small" do
      let(:options) { minimal_options.merge(idle_timeout: 9_999) }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "idle_timeout must be equal to 0 or idle_timeout must be greater than or equal to 10000")
      end
    end

    context "when valid provided" do
      let(:options) { minimal_options.merge(idle_timeout: 10_001) }

      it "is set" do
        expect(hikari_config.idle_timeout).to eq 10_001
      end
    end

    context "when 0" do
      let(:options) { minimal_options.merge(idle_timeout: 0) }

      it "is set" do
        expect(hikari_config.idle_timeout).to eq 0
      end
    end
  end

  describe "jdbc_url" do
    context "when set together with adapter" do
      let(:options) { minimal_options.merge(jdbc_url: "jdbc:postgresql://postgres/hucpa") }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "adapter/jdbc_url options are invalid. Either adapter or jdbc_url must be filled")
      end
    end
  end

  describe "server_name" do
    context "when empty" do
      let(:options) { minimal_options.merge(server_name: "") }

      it "is invalid" do
        expect do
          hikari_config
        end.to raise_error(ArgumentError, "server_name must be filled")
      end
    end
  end
end

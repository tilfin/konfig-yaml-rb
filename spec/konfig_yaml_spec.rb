require 'spec_helper'
require 'yaml'

describe KonfigYaml do
  describe '#initialize' do
    describe 'option name, env' do
      before do
        ENV['RUBY_ENV'] = nil
        ENV['RAILS_ENV'] = nil
        ENV['RACK_ENV'] = nil
      end

      subject { described_class.new('another') }

      it 'not specified' do
        expect(subject.short_env).to eq('dev')
      end

      it 'specified symbol' do
        sbj = described_class.new('another', env: 'staging')
        expect(sbj.short_env).to eq('stg')
      end

      it 'specified string' do
        sbj = described_class.new('another', env: :production)
        expect(sbj.short_env).to eq('prd')
      end

      context 'setenv RUBY_ENV' do
        before { ENV['RUBY_ENV'] = 'production' }
        after  { ENV['RUBY_ENV'] = nil }

        it { expect(subject.short_env).to eq('prd') }
      end

      context 'setenv RAILS_ENV' do
        before { ENV['RAILS_ENV'] = 'staging' }
        after  { ENV['RAILS_ENV'] = nil }

        it { expect(subject.short_env).to eq('stg') }
      end

      context 'setenv RACK_ENV' do
        before { ENV['RACK_ENV'] = 'integration' }
        after  { ENV['RACK_ENV'] = nil }

        it { expect(subject.short_env).to eq('default') }
      end

      context 'setenv RUBY_ENV, RAILS_ENV' do
        before do
          ENV['RUBY_ENV'] = 'production'
          ENV['RAILS_ENV'] = 'staging'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['RAILS_ENV'] = nil
        end

        it { expect(subject.short_env).to eq('prd') }
      end

      context 'setenv RAILS_ENV, RACK_ENV' do
        before do
          ENV['RAILS_ENV'] = 'staging'
          ENV['RACK_ENV'] = 'integration'
        end

        after do
          ENV['RAILS_ENV'] = nil
          ENV['RACK_ENV'] = nil
        end

        it { expect(subject.short_env).to eq('stg') }
      end

      context 'setenv RUBY_ENV, RAILS_ENV, RACK_ENV' do
        before do
          ENV['RUBY_ENV'] = 'production'
          ENV['RAILS_ENV'] = 'staging'
          ENV['RACK_ENV'] = 'integration'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['RAILS_ENV'] = nil
          ENV['RACK_ENV'] = nil
        end

        it { expect(subject.short_env).to eq('prd') }
      end
    end

    describe 'option path' do
      let!(:path) { File.expand_path("../fixtures", __FILE__) }

      context 'name is not specified' do
        subject { described_class.new(path: path) }

        it 'loads app.yaml' do
          expect { subject }.to_not raise_error
        end
      end

      context 'name is specified' do
        subject { described_class.new('another', path: path) }

        it 'loads another.yml' do
          expect { subject }.to_not raise_error
        end
      end

      context "name's file does not exist" do
        subject { described_class.new('none', path: path) }

        it 'raises an error' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end

    describe 'option erb' do
      let!(:path) { File.expand_path("../fixtures", __FILE__) }
      let!(:pre_instance) { described_class.new }

      context 'not specified' do
        subject { described_class.new('erb_config', path: path) }

        it 'loads without evaluating ERB' do
          expect(subject.label).to eq '<%= 3 * 15 %>seconds'
        end
      end

      context 'true' do
        subject { described_class.new('erb_config', path: path, erb: true) }

        it 'loads with evaluating ERB' do
          expect(subject.label).to eq '45seconds'
        end
      end

      context 'false' do
        subject { described_class.new('erb_config', path: path, erb: false) }

        it 'loads without evaluating ERB' do
          expect(subject.label).to eq '<%= 3 * 15 %>seconds'
        end
      end
    end
  end

  describe '#setup' do
    let!(:path) { File.expand_path("../fixtures", __FILE__) }

    context 'without block' do
      it 'defines Settings class' do
        described_class.setup

        expect(Settings.log.file).to eq('log/app.log')
      end
    end

    context 'with block' do
      it 'defines SettingsB class' do
        described_class.setup do |config|
          config.name = 'another'
          config.path = path
          config.const_name = 'SettingsB'
        end

        expect(SettingsB.log.level).to eq('debug')
        expect(SettingsB.short_env).to eq('dev')
      end
    end
  end

  describe 'merged configuraton' do
    subject { described_class.new('app', path: 'config', env: env) }

    context 'environment is development' do
      let!(:env) { 'development' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('localhost')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('http://localhost')
        expect(subject.log.level).to eq('debug')
        expect(subject.log.file).to eq('log/app.log')
        expect{ subject.bucket }.to raise_error(NoMethodError)
        expect{ subject.bucket_path }.to raise_error(NoMethodError)
        expect{ subject.cloud_access_key }.to raise_error(NoMethodError)
        expect(subject[:cloud_access_key]).to be_nil
        expect(subject.access_limits).to eq ['127.0.0.1']
        expect(subject.entries[0]).to eq 0
        expect(subject.entries[1].name).to eq 'A'
        expect(subject.entries[1].value).to eq 1
        expect(subject.entries[2].name).to eq 'B'
        expect(subject.entries[2].value).to eq 2
      end
    end

    context 'environment is test' do
      let!(:env) { 'test' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('localhost')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('http://localhost')
        expect(subject.log.level).to eq('error')
        expect(subject.log.file).to eq('log/test.log')
        expect{ subject.bucket }.to raise_error(NoMethodError)
        expect{ subject.bucket_path }.to raise_error(NoMethodError)
        expect{ subject.cloud_access_key }.to raise_error(NoMethodError)
        expect(subject['cloud_access_key']).to be_nil
        expect(subject.access_limits).to eq ['127.0.0.1']
      end

      context 'defined environment variables' do
        before do
          ENV['RUBY_ENV'] = 'test'
        end

        after do
          ENV['RUBY_ENV'] = nil
        end

        it 'expands environment variables' do
          expect(subject.db.host).to eq('localhost')
          expect(subject.db.name).to eq('service-test')
          expect(subject.db.user).to eq('user')
          expect(subject.db.pass).to eq('password')
        end
      end
    end

    context 'environment is integration' do
      let!(:env) { 'integration' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('https://api-itg.example.com')
        expect(subject.log.level).to eq('info')
        expect(subject.log[:file]).to be_nil
        expect(subject.bucket).to eq('storage-service-stg')
        expect(subject.bucket_path).to eq('/itg')
        expect(subject.cloud_access_key).to eq('aaabbbccc')
        expect(subject.access_limits).to eq ['192.168.0.0/24', '10.0.0.0/8']
      end

      context 'defined environment variables' do
        before do
          ENV['RUBY_ENV'] = 'integration'
          ENV['DATABASE_HOST'] = 'db-itg.example.com'
          ENV['DATABASE_USER'] = 'itg_user'
          ENV['DATABASE_PASSWORD'] = 'PassworD'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['DATABASE_HOST'] = nil
          ENV['DATABASE_USER'] = nil
          ENV['DATABASE_PASSWORD'] = nil
        end

        it 'expands environment variables' do
          expect(subject.db.host).to eq('db-itg.example.com')
          expect(subject.db.name).to eq('service-integration')
          expect(subject.db.user).to eq('itg_user')
          expect(subject.db.pass).to eq('PassworD')
        end
      end
    end

    context 'environment is staging' do
      let!(:env) { 'staging' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('https://api-stg.example.com')
        expect(subject.log.level).to eq('info')
        expect(subject.log['file']).to be_nil
        expect(subject.bucket).to eq('storage-service-stg')
        expect(subject.bucket_path).to eq('/stg')
        expect(subject.cloud_access_key).to eq('aaabbbccc')
        expect(subject.access_limits).to eq ['192.168.0.0/24', '10.0.0.0/8']
      end

      context 'defined environment variables' do
        before do
          ENV['RUBY_ENV'] = 'staging'
          ENV['DATABASE_HOST'] = 'db-stg.example.com'
          ENV['DATABASE_USER'] = 'stg_user'
          ENV['DATABASE_PASSWORD'] = 'PassworD'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['DATABASE_HOST'] = nil
          ENV['DATABASE_USER'] = nil
          ENV['DATABASE_PASSWORD'] = nil
        end

        it 'expands environment variables' do
          expect(subject.db.host).to eq('db-stg.example.com')
          expect(subject.db.name).to eq('service-staging')
          expect(subject.db.user).to eq('stg_user')
          expect(subject.db.pass).to eq('PassworD')
        end
      end
    end

    context 'environment is preproduction' do
      let!(:env) { 'preproduction' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('https://api-pre.example.com')
        expect(subject.log.level).to eq('warn')
        expect(subject.log[:file]).to be_nil
        expect(subject.bucket).to eq('storage-service-stg')
        expect(subject.bucket_path).to eq('/pre')
        expect(subject.cloud_access_key).to eq('aaabbbccc')
        expect(subject.access_limits).to eq ['192.168.0.0/24', '10.0.0.0/8']
      end

      context 'defined environment variables' do
        before do
          ENV['RUBY_ENV'] = 'preproduction'
          ENV['DATABASE_HOST'] = 'db-prod.example.com'
          ENV['DATABASE_USER'] = 'preprod_user'
          ENV['DATABASE_PASSWORD'] = '4s5gsUoP'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['DATABASE_HOST'] = nil
          ENV['DATABASE_USER'] = nil
          ENV['DATABASE_PASSWORD'] = nil
        end

        it 'expands environment variables' do
          expect(subject.db.host).to eq('db-prod.example.com')
          expect(subject.db.name).to eq('service-preproduction')
          expect(subject.db.user).to eq('preprod_user')
          expect(subject.db.pass).to eq('4s5gsUoP')
        end
      end
    end

    context 'environment is production' do
      let!(:env) { 'production' }

      it 'an instance that has accessors by method' do
        expect(subject.port).to eq(1080)
        expect(subject.db.host).to eq('')
        expect(subject.db.name).to eq('service-development')
        expect(subject.db.user).to eq('user')
        expect(subject.db.pass).to eq('password')
        expect(subject.root_url).to eq('https://api.example.com')
        expect(subject.log.level).to eq('error')
        expect(subject.log['file']).to be_nil
        expect(subject.bucket).to eq('storage-service')
        expect(subject.bucket_path).to eq('/')
        expect(subject.cloud_access_key).to eq('xxxyyyzzz')
        expect(subject.access_limits).to be_nil
      end

      context 'defined environment variables' do
        before do
          ENV['RUBY_ENV'] = 'production'
          ENV['DATABASE_HOST'] = 'db-prod.example.com'
          ENV['DATABASE_USER'] = 'prod_user'
          ENV['DATABASE_PASSWORD'] = '3kszdf4aR'
        end

        after do
          ENV['RUBY_ENV'] = nil
          ENV['DATABASE_HOST'] = nil
          ENV['DATABASE_USER'] = nil
          ENV['DATABASE_PASSWORD'] = nil
        end

        it 'expands environment variables' do
          expect(subject.db.host).to eq('db-prod.example.com')
          expect(subject.db.name).to eq('service-production')
          expect(subject.db.user).to eq('prod_user')
          expect(subject.db.pass).to eq('3kszdf4aR')
        end
      end
    end
  end
end

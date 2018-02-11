require 'spec_helper'
require 'yaml'

describe KonfigYaml do
  describe '#initialize' do
    describe 'option name, env' do
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

    describe 'option use_cache' do
      let!(:path) { File.expand_path("../fixtures", __FILE__) }
      let!(:pre_instance) { described_class.new }

      before do
        allow_any_instance_of(described_class).to receive(:load_file).and_raise('load_file called')
      end

      context 'not specified' do
        subject { described_class.new }

        it 'loads cached instance without calling load_file' do
          expect{ subject }.not_to raise_error 'load_file called'
        end
      end

      context 'true' do
        subject { described_class.new(use_cache: true) }

        it 'loads cached instance without calling load_file' do
          expect{ subject }.not_to raise_error 'load_file called'
        end

        context 'after cache cleared' do
          before { described_class.clear }

          it 'loads new instance with calling load_file' do
            expect{ subject }.to raise_error 'load_file called'
          end
        end
      end

      context 'false' do
        subject { described_class.new(use_cache: false) }

        it 'loads new instance with calling load_file' do
          expect{ subject }.to raise_error 'load_file called'
        end
      end
    end
  end

  describe 'accessors' do
    subject { described_class.new('app', path: 'config') }

    it 'an instance that has accessors by method' do
      expect(subject.port).to eq(8080)
      expect(subject.logger.level).to eq('info')
      expect(subject.db.name).to eq('-app-development')
    end

    it 'an instance that has accessors by symbol' do
      expect(subject[:port]).to eq(8080)
      expect(subject[:logger][:level]).to eq('info')
    end

    it 'an instance that has accessors by string' do
      expect(subject['port']).to eq(8080)
      expect(subject['logger']['level']).to eq('info')
    end

    it 'an instance that has accessors by various ways' do
      expect(subject.logger[:level]).to eq('info')
      expect(subject.logger['level']).to eq('info')
      expect(subject[:logger].level).to eq('info')
      expect(subject[:logger]['level']).to eq('info')
      expect(subject['logger'].level).to eq('info')
      expect(subject['logger'][:level]).to eq('info')
    end

    context 'defined BRAND' do
      before { ENV['BRAND'] = 'awesome' }
      after { ENV['BRAND'] = nil }

      it 'expands undefined ENV value as default' do
        expect(subject.db.name).to eq('awesome-app-development')
      end
    end

    context 'environment is production' do
      before { ENV['RUBY_ENV'] = 'production' }
      after { ENV['RUBY_ENV'] = nil }

      it 'an instance that provides the values overwritten by values of production:' do
        expect(subject.port).to eq(1080)
        expect(subject[:logger]['level']).to eq('error')
        expect(subject.db.name).to eq('-app-production')
      end

      context 'defined BRAND' do
        before { ENV['BRAND'] = 'brand' }
        after { ENV['BRAND'] = nil }

        it 'expands defined ENV value' do
          expect(subject.db.name).to eq('brand-app-production')
        end
      end
    end
  end
end

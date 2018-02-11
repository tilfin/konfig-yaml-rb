require 'spec_helper'
require 'yaml'

describe KonfigYaml do
  describe '#initialize' do
    subject { described_class.new }

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

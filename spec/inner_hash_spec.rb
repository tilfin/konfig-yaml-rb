require 'spec_helper'
require 'yaml'

describe KonfigYaml::InnerHash do
  subject { described_class.new(h) }

  let!(:h) do
    {
      'port' => 80,
      'logger' => { 'level' => 'warn' }
    }
  end

  describe '#initialize' do
    it 'an instance that has accessors by method' do
      expect(subject.port).to eq(80)
      expect(subject.logger.level).to eq('warn')
    end

    it 'an instance that has accessors by symbol' do
      expect(subject[:port]).to eq(80)
      expect(subject[:logger][:level]).to eq('warn')
    end

    it 'an instance that has accessors by string' do
      expect(subject['port']).to eq(80)
      expect(subject['logger']['level']).to eq('warn')
    end

    it 'an instance that has accessors by various ways' do
      expect(subject.logger[:level]).to eq('warn')
      expect(subject.logger['level']).to eq('warn')
      expect(subject[:logger].level).to eq('warn')
      expect(subject[:logger]['level']).to eq('warn')
      expect(subject['logger'].level).to eq('warn')
      expect(subject['logger'][:level]).to eq('warn')
    end
  end

  describe '#to_h' do
    let!(:h_symbol) do
      {
        port: 80,
        logger: { level: 'warn' }
      }
    end

    it 'creates an hash with name as symbol' do
      expect(subject.to_h).to eq(h_symbol)
    end

    it 'creates an hash with name as symbol' do
      expect(subject.to_h(symbolize_names: true)).to eq(h_symbol)
    end

    it 'creates an hash with name as string' do
      expect(subject.to_h(symbolize_names: false)).to eq(h)
    end
  end
end

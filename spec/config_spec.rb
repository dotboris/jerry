require 'jerry/config'
require 'fixtures/house'

describe Jerry::Config do
  let(:config_klass) { Class.new Jerry::Config }
  let(:config) { config_klass.new }
  let(:jerry) { double 'jerry' }

  before do
    config.jerry = jerry
  end

  describe '::bind' do
    it 'should create a class provider' do
      klass = double 'class'
      args = [Class.new, :foobar, -> { 'stuff' }]
      expect(Jerry::ClassProvider).to receive(:new).with(klass, args)

      Class.new Jerry::Config do
        bind klass, args
      end
    end

    it 'should default ctor_args to empty array' do
      expect(Jerry::ClassProvider).to receive(:new).with(anything, [])

      Class.new Jerry::Config do
        bind Class.new
      end
    end
  end

  describe '#[]' do
    it 'should get the provider instance from ::bind' do
      instance = double 'instance'
      klass = double 'class', new: instance

      config_klass.class_eval do
        bind klass
      end

      expect(config[klass]).to eq instance
    end

    it 'should pass jerry to the provider' do
      provider = double 'provider'
      config_klass.send(:providers)[:foobar] = provider

      expect(provider).to receive(:call).with(jerry)

      config[:foobar]
    end

    it 'should fail when provider is missing' do
      expect { config[:not_there] }.to raise_error(Jerry::InstanciationError)
    end
  end
end

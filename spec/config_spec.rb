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

    it 'should set self to config instance for all procs in spec' do
      klass = Class.new do
        attr_reader :thing
        define_method(:initialize) { |thing| @thing = thing }
      end
      config_klass = Class.new(Jerry::Config) do
        define_method(:initialize) { @foobar = 'something private' }
        bind klass, [proc { @foobar }]
      end
      config = config_klass.new

      instance = config[klass]
      expect(instance.thing).to eq 'something private'
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

      expect(provider).to receive(:call).with(jerry, anything)

      config[:foobar]
    end

    it 'should pass config instance to the provider' do
      provider = double 'provider'
      config_klass.providers[:something] = provider

      expect(provider).to receive(:call).with(anything, config)

      config[:something]
    end

    it 'should fail when provider is missing' do
      expect { config[:not_there] }.to raise_error(Jerry::InstanciationError)
    end

    it 'should wrap errors from the provider' do
      provider = double 'provider'
      allow(provider).to receive(:call)
        .and_raise(RuntimeError, 'something blew up')
      config_klass.providers[:failing] = provider

      expect { config[:failing] }
        .to raise_error(Jerry::InstanciationError) do |e|
        expect(e.cause.message).to eq 'something blew up'
      end
    end
  end

  describe '#knows?' do
    it 'should be true if key is in providers' do
      key = double 'some key'
      config_klass.providers[key] = double 'some provider'

      expect(config.knows? key).to be true
    end

    it 'should be false if key is not known' do
      expect(config.knows? double('some unknown key')).to be false
    end
  end
end

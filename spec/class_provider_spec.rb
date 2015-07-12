require 'jerry/class_provider'

describe Jerry::ClassProvider do
  let(:jerry) { double 'jerry' }
  let(:config) { double 'config' }
  let(:klass) { dummy_class }

  def dummy_class
    Class.new do
      define_method(:initialize) { |*| }
    end
  end

  describe '#call' do
    it 'should return an instance of the class' do
      provider = Jerry::ClassProvider.new klass, []
      instance = double 'instance'
      allow(klass).to receive(:new).and_return(instance)

      expect(provider.call jerry, config).to eq instance
    end

    it 'should pass constructor arguments in the right order' do
      provider = Jerry::ClassProvider.new klass, [
        proc { 'fi' }, proc { 'fo' }, proc { 'fum' }]

      expect(klass).to receive(:new).with('fi', 'fo', 'fum')

      provider.call jerry, config
    end
  end

  describe 'with a class argument' do
    it 'should get the instance from jerry' do
      arg_klass = dummy_class
      provider = Jerry::ClassProvider.new klass, [arg_klass]

      expect(jerry).to receive(:[]).with(arg_klass)

      provider.call jerry, config
    end

    it 'should pass the instance from jerry to the constructor' do
      provider = Jerry::ClassProvider.new klass, [dummy_class]
      instance = double 'instance'
      allow(jerry).to receive(:[]).and_return(instance)

      expect(klass).to receive(:new).with(instance)

      provider.call jerry, config
    end
  end

  describe 'with a symbol argument' do
    it 'should get the instance from jerry' do
      provider = Jerry::ClassProvider.new klass, [:foobar]

      expect(jerry).to receive(:[]).with(:foobar)

      provider.call jerry, config
    end

    it 'should pass the instance from jerry to the constructor' do
      provider = Jerry::ClassProvider.new klass, [:foobar]
      instance = double 'instance'
      allow(jerry).to receive(:[]).with(:foobar).and_return(instance)

      expect(klass).to receive(:new).with(instance)

      provider.call jerry, config
    end
  end

  describe 'with callable argument' do
    it 'should call the callable' do
      expect do |callable|
        provider = Jerry::ClassProvider.new klass, [callable.to_proc]
        provider.call jerry, config
      end.to yield_control
    end

    it 'should pass the result of the callable to the constructor' do
      instance = double 'instance'
      provider = Jerry::ClassProvider.new klass, [proc { instance }]

      expect(klass).to receive(:new).with(instance)

      provider.call jerry, config
    end

    it 'should pass the jerry and config instance to the proc' do
      expect do |callable|
        provider = Jerry::ClassProvider.new klass, [callable.to_proc]
        provider.call jerry, config
      end.to yield_with_args(jerry, config)
    end

    it 'should call the proc in the context of the config' do
      config = double 'config'
      config.instance_eval { @stuff = 'something private' }
      callable = proc { @stuff }
      provider = Jerry::ClassProvider.new klass, [callable]

      expect(klass).to receive(:new).with('something private')

      provider.call jerry, config
    end
  end
end

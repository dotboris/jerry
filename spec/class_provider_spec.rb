require 'jerry/class_provider'

describe ClassProvider do
  let(:jerry) { double 'jerry' }
  let(:klass) { dummy_class }

  def dummy_class
    Class.new do
      define_method(:initialize) { |*| }
    end
  end

  describe '#call' do
    it 'should return an instance of the class' do
      provider = ClassProvider.new jerry, klass, []
      instance = double 'instance'
      allow(klass).to receive(:new).and_return(instance)

      expect(provider.call).to eq instance
    end

    it 'should pass constructor arguments in the right order' do
      provider = ClassProvider.new jerry, klass, [
        -> { 'fi' }, -> { 'fo' }, -> { 'fum' }
      ]

      expect(klass).to receive(:new).with('fi', 'fo', 'fum')

      provider.call
    end
  end

  describe 'with a class argument' do
    it 'should get the instance from jerry' do
      arg_klass = dummy_class
      provider = ClassProvider.new jerry, klass, [arg_klass]

      expect(jerry).to receive(:[]).with(arg_klass)

      provider.call
    end

    it 'should pass the instance from jerry to the constructor' do
      provider = ClassProvider.new jerry, klass, [dummy_class]
      instance = double 'instance'
      allow(jerry).to receive(:[]).and_return(instance)

      expect(klass).to receive(:new).with(instance)

      provider.call
    end
  end

  describe 'with a symbol argument' do
    it 'should get the instance from jerry' do
      provider = ClassProvider.new jerry, klass, [:foobar]

      expect(jerry).to receive(:[]).with(:foobar)

      provider.call
    end

    it 'should pass the instance from jerry to the constructor' do
      provider = ClassProvider.new jerry, klass, [:foobar]
      instance = double 'instance'
      allow(jerry).to receive(:[]).with(:foobar).and_return(instance)

      expect(klass).to receive(:new).with(instance)

      provider.call
    end
  end

  describe 'with callable argument' do
    it 'should call the callable' do
      callable = double 'callable'
      provider = ClassProvider.new jerry, klass, [callable]

      expect(callable).to receive(:call)

      provider.call
    end

    it 'should pass the result of the callable to the constructor' do
      instance = double 'instance'
      provider = ClassProvider.new jerry, klass, [-> { instance }]

      expect(klass).to receive(:new).with(instance)

      provider.call
    end
  end
end

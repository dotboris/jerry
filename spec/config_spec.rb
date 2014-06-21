require 'rspec'
require 'jerry/config'

describe Jerry::Config do
  let(:klass) {Class.new(Jerry::Config)}

  it 'should extend the its subclass with Jerry::Sugar when inherited' do
    expect(klass.singleton_class.included_modules).to include Jerry::Sugar
    expect(klass).to respond_to :components
    expect(klass).to respond_to :component
  end

  describe '#components' do
    it 'should call the class contents method' do
      instance = klass.new

      expect(klass).to receive(:components).and_return([:something])

      expect(instance.components).to eq([:something])
    end
  end

  describe '#rig' do
    it 'should call rig on the previously set jerry' do
      jerry = double('jerry')
      config = klass.new
      config.jerry = jerry

      expect(jerry).to receive(:rig).with(:target)

      config.instance_eval { rig :target }
    end

    it 'should return the result from the jerry rig method' do
      jerry = double('jerry')
      allow(jerry).to receive(:rig).with(anything).and_return 42
      config = klass.new
      config.jerry = jerry

      expect(config.instance_eval { rig :something }).to eq(42)
    end
  end

  describe '#knows?' do
    it 'should call the knows? method on the previously set jerry' do
      jerry = double('jerry')
      config = klass.new
      config.jerry = jerry

      expect(jerry).to receive(:knows?).with(:target)

      config.instance_eval { knows? :target }
    end

    it 'should return the results from the jerry knows? method' do
      jerry = double('jerry')
      allow(jerry).to receive(:knows?).with(anything).and_return true
      config = klass.new
      config.jerry = jerry

      expect(config.instance_eval { knows? :something }).to be_truthy
    end
  end
end
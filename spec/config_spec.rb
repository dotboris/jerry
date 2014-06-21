require 'rspec'
require 'jerry/config'

describe Jerry::Config do
  it 'should extend the its subclass with Jerry::Sugar when inherited' do
    klass = Class.new(Jerry::Config)

    expect(klass.singleton_class.included_modules).to include Jerry::Sugar
    expect(klass).to respond_to :components
    expect(klass).to respond_to :component
  end

  describe '#components' do
    it 'should call the class contents method' do
      klass = Class.new(Jerry::Config)
      instance = klass.new

      expect(klass).to receive(:components).and_return([:something])

      expect(instance.components).to eq([:something])
    end
  end
end
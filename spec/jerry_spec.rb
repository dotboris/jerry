require 'jerry'

describe Jerry do
  def double_config(name, fields = {})
    config = double name, fields
    allow(config).to receive(:jerry=)
    config
  end

  it 'should set the jerry attribute on the configs' do
    alfa = spy 'alfa config'
    bravo = spy 'bravo config'
    charlie = spy 'charlie config'

    jerry = Jerry.new alfa, bravo, charlie

    expect(alfa).to have_received(:jerry=).with(jerry)
    expect(bravo).to have_received(:jerry=).with(jerry)
    expect(charlie).to have_received(:jerry=).with(jerry)
  end

  describe '#[]' do
    it 'should delegate to configs' do
      config = double_config 'config'
      allow(config).to receive(:knows?).and_return(true)
      jerry = Jerry.new config

      expect(config).to receive(:[]).with(House)

      jerry[House]
    end

    it 'should return the provided value from the config' do
      instance = double 'some value'
      config = double_config 'config'
      allow(config).to receive(:knows?).and_return(true)
      allow(config).to receive(:[]).and_return(instance)
      jerry = Jerry.new config

      expect(jerry[House]).to eq instance
    end

    it 'should prioritize configs by their order in the constructor' do
      alfa = double_config 'alfa config'
      allow(alfa).to receive(:knows?).and_return(false)
      bravo = double_config 'bravo config'
      allow(bravo).to receive(:knows?).and_return(true)
      bravo_instance = double 'instance from bravo'
      allow(bravo).to receive(:[]).and_return(bravo_instance)
      charlie = double_config 'charlie config'
      allow(charlie).to receive(:knows?).and_return(true)
      charlie_instance = double 'instance from charlie'
      allow(charlie).to receive(:[]).and_return(charlie_instance)

      jerry = Jerry.new alfa, bravo, charlie

      expect(jerry[:something]).to eq bravo_instance
    end

    it 'should fail if no config know the key' do
      configs = 3.times.map { double_config 'some config', knows?: false }
      jerry = Jerry.new(*configs)

      expect { jerry[:not_there] }.to raise_error(Jerry::InstantiationError)
    end
  end
end

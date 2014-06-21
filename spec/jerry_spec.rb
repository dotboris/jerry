require 'rspec'
require 'jerry'

describe Jerry do
  it 'should work with all the pieces' do
    house = Class.new do
      attr_reader :window, :door

      def initialize(window, door)
        @window = window
        @door = door
      end
    end
    window = Class.new
    door = Class.new

    config = Class.new(Jerry::Config) do
      component(:window) { window.new }
      component(:door) { door.new }
      component(:house) {
        house.new rig(:window), rig(:door)
      }
    end
    jerry = Jerry.new config.new

    instance = jerry.rig :house

    expect(instance).not_to be_nil
    expect(instance).to be_a house
    expect(instance.window).not_to be_nil
    expect(instance.window).to be_a window
    expect(instance.door).not_to be_nil
    expect(instance.door).to be_a door
  end

  describe '#rig' do
    it 'should raise error if the component does not exist' do
      jerry = Jerry.new

      expect{jerry.rig :not_actually_a_thing}.to raise_error(Jerry::RigError)
    end

    it 'should call the component method on the config' do
      config = double('config', components: [:doomsday_device]).as_null_object
      jerry = Jerry.new config

      expect(config).to receive(:doomsday_device).with(no_args)

      jerry.rig :doomsday_device
    end

    it 'should call the component method registered last' do
      target = double('target')
      jerry = Jerry.new double('old config', components: [:target]).as_null_object,
                        double('new config', components: [:target], target: target).as_null_object

      component = jerry.rig :target

      expect(component).to eq(target)
    end
  end

  describe '#<<' do
    let(:jerry) { Jerry.new }

    it 'should fetch the config components' do
      config = double('config').as_null_object

      expect(config).to receive(:components).and_return([])

      jerry << config
    end

    it 'should register components' do
      config = double('config', components: [:target]).as_null_object

      jerry << config

      expect(jerry.knows? :target).to be_truthy
    end

    it 'should overwrite previous components' do
      target = double('target')
      config = double('config', components: [:target], target: target).as_null_object

      jerry << config

      expect(jerry.rig :target).to eq(target)
    end

    it 'should pass an instance of itself to the config' do
      config = double('config', components: []).as_null_object

      expect(config).to receive(:jerry=).with(jerry)

      jerry << config
    end
  end

  describe '#knows?' do
    it 'should be true when the component is defined by a config' do
      jerry = Jerry.new double('config', components: [:target]).as_null_object

      expect(jerry.knows? :target).to be_truthy
    end

    it 'should be false if the component is defined by no config' do
      jerry = Jerry.new double('config', components: [:not_target]).as_null_object

      expect(jerry.knows? :target).to be_falsey
    end
  end

  describe '#initialize' do
    it 'should register all the config components' do
      configs = 'a'.upto('c').map {|i| double("config #{i}", components: [i.to_sym]).as_null_object}
      jerry = Jerry.new(*configs)

      expect(jerry.knows? :a).to be_truthy
      expect(jerry.knows? :b).to be_truthy
      expect(jerry.knows? :c).to be_truthy
    end

    it 'should give priority to the components of later configs' do
      target = double('target')
      jerry = Jerry.new double('old config', components: [:target]).as_null_object,
                        double('new config', components: [:target], target: target).as_null_object

      expect(jerry.rig :target).to eq(target)
    end
  end
end
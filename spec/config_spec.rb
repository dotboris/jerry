require 'rspec'
require 'jerry/config'

describe Jerry::Config do
  let(:klass) {Class.new(Jerry::Config)}

  describe 'subclass' do
    it 'should respond to all inherited class methods' do
      expect(klass).to respond_to :components
      expect(klass).to respond_to :component
    end
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

  describe 'class methods' do
    describe '#component' do
      it 'should create a method with the given name' do
        klass.component(:my_component) {}

        expect(klass.new).to respond_to(:my_component)
      end

      it 'should add the name to the list of components' do
        klass.component(:target) {}

        expect(klass.components).to include(:target)
      end

      it 'should raise an error when scope is unknown' do
        expect{klass.component(:target, scope: :not_a_thing) {}}.to raise_error(Jerry::ComponentError)
      end

      it 'should raise an error when block is missing' do
        expect{klass.component :target}.to raise_error(Jerry::ComponentError)
      end

      describe 'defined method' do
        it 'should have the right self set' do
          klass.component(:_self) { self }
          instance = klass.new

          expect(instance._self).not_to be_a Class
          expect(instance._self).to be_a klass
          expect(instance._self).to eq(instance)
        end

        context 'with scope set to :single' do
          it 'should only call the block once' do
            call_count = 0
            klass.component(:target, scope: :single) {call_count += 1}
            instance = klass.new

            3.times {instance.target}

            expect(call_count).to eq(1)
          end

          it 'should keep returning the first created component' do
            call_count = 0
            klass.component(:target, scope: :single) {call_count += 1}
            instance = klass.new

            expect(instance.target).to eq(1)
            expect(instance.target).to eq(1)
            expect(instance.target).to eq(1)
          end
        end

        context 'with scope set to :instance' do
          it 'should call the block every time' do
            call_count = 0
            klass.component(:target, scope: :instance) {call_count += 1}
            instance = klass.new

            3.times {instance.target}

            expect(call_count).to eq(3)
          end

          it 'should return a new instance every time' do
            call_count = 0
            klass.component(:target, scope: :instance) {call_count += 1}
            instance = klass.new

            expect(instance.target).to eq(1)
            expect(instance.target).to eq(2)
            expect(instance.target).to eq(3)
          end
        end

        context 'with no scope' do
          it 'should only call the block once' do
            call_count = 0
            klass.component(:target) {call_count += 1}
            instance = klass.new

            3.times {instance.target}

            expect(call_count).to eq(1)
          end

          it 'should keep returning the first created component' do
            call_count = 0
            klass.component(:target) {call_count += 1}
            instance = klass.new

            expect(instance.target).to eq(1)
            expect(instance.target).to eq(1)
            expect(instance.target).to eq(1)
          end
        end
      end
    end

    describe '#components' do
      it 'should default to an empty array' do
        expect(klass.components).to eq([])
      end
    end
  end
end
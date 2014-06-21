require 'rspec'
require 'jerry/config'

describe Jerry::Sugar do
  let(:sugar) {Class.new Jerry::Config}

  describe '#component' do
    it 'should create a method with the given name' do
      sugar.component(:my_component) {}

      expect(sugar.new).to respond_to(:my_component)
    end

    it 'should add the name to the list of components' do
      sugar.component(:target) {}

      expect(sugar.components).to include(:target)
    end

    it 'should raise an error when scope is unknown' do
      expect{sugar.component(:target, scope: :not_a_thing) {}}.to raise_error(Jerry::ComponentError)
    end

    it 'should raise an error when block is missing' do
      expect{sugar.component :target}.to raise_error(Jerry::ComponentError)
    end

    describe 'defined method' do
      it 'should have the right self set' do
        sugar.component(:_self) { self }
        instance = sugar.new

        expect(instance._self).not_to be_a Class
        expect(instance._self).to be_a sugar
        expect(instance._self).to eq(instance)
      end

      context 'with scope set to :single' do
        it 'should only call the block once' do
          call_count = 0
          sugar.component(:target, scope: :single) {call_count += 1}
          instance = sugar.new

          3.times {instance.target}

          expect(call_count).to eq(1)
        end

        it 'should keep returning the first created component' do
          call_count = 0
          sugar.component(:target, scope: :single) {call_count += 1}
          instance = sugar.new

          expect(instance.target).to eq(1)
          expect(instance.target).to eq(1)
          expect(instance.target).to eq(1)
        end
      end

      context 'with scope set to :instance' do
        it 'should call the block every time' do
          call_count = 0
          sugar.component(:target, scope: :instance) {call_count += 1}
          instance = sugar.new

          3.times {instance.target}

          expect(call_count).to eq(3)
        end

        it 'should return a new instance every time' do
          call_count = 0
          sugar.component(:target, scope: :instance) {call_count += 1}
          instance = sugar.new

          expect(instance.target).to eq(1)
          expect(instance.target).to eq(2)
          expect(instance.target).to eq(3)
        end
      end

      context 'with no scope' do
        it 'should only call the block once' do
          call_count = 0
          sugar.component(:target) {call_count += 1}
          instance = sugar.new

          3.times {instance.target}

          expect(call_count).to eq(1)
        end

        it 'should keep returning the first created component' do
          call_count = 0
          sugar.component(:target) {call_count += 1}
          instance = sugar.new

          expect(instance.target).to eq(1)
          expect(instance.target).to eq(1)
          expect(instance.target).to eq(1)
        end
      end
    end
  end

  describe '#components' do
    it 'should default to an empty array' do
      expect(sugar.components).to eq([])
    end
  end
end
describe Jerry::Error do
  def raise_error_with_cause
    raise 'Something went wrong'
  rescue RuntimeError
    raise Jerry::Error, 'wrapping error'
  end

  it 'should record the causing exception when there is one' do
    expect { raise_error_with_cause }.to raise_error(Jerry::Error) do |ex|
      expect(ex.cause.message).to eq 'Something went wrong'
    end
  end

  it 'should not record the causing exception when there is none' do
    expect { raise Jerry::Error }.to raise_error(Jerry::Error) do |ex|
      expect(ex.cause).to be_nil
    end
  end

  it 'should have a message' do
    expect { raise Jerry::Error, ':(' }.to raise_error(Jerry::Error, ':(')
  end
end

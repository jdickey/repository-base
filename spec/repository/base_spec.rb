require 'spec_helper'

describe Repository::Base do
  it 'has a version number' do
    expect(Repository::Base::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end

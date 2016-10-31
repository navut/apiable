require 'spec_helper'

class Dummy
  include Apiable::Object

  def name
    'John Doe'
  end

  def level
    :beginner
  end

  def senior
    false
  end

  outside :name
  outside :level
  outside :senior
end

describe Dummy do
  let(:object) { Dummy.new }

  it 'returns hash' do
    expect {
      object.to_external
    }.to include(name: 'John Doe')

    expect {
      object.to_external
    }.to include(level: :beginner)

    expect {
      object.to_external
    }.to include(senior: false)
  end
end

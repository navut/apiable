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

  outgoing :name
  outgoing :level
  outgoing :senior
end

describe Dummy do
  let(:object) { Dummy.new }

  it 'returns hash' do
    expect(object.external).to include({ name: 'John Doe' })
    expect(object.external).to include({ level: :beginner })
    expect(object.external).to include({ senior: false })
  end
end

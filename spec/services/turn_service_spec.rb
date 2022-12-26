require 'rails_helper'

describe 'TurnService' do
  subject { TurnService }

  specify '.next_turn_type' do
    expect(subject.next_turn_type(build(:turn, type: Turn::SPRING))).to eq(Turn::SPRING_RETREAT)
    expect(subject.next_turn_type(build(:turn, type: Turn::WINTER))).to eq(Turn::SPRING)
  end
end

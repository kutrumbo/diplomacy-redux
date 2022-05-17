require 'rails_helper'

describe 'PathService' do
  subject { PathService }

  describe '.possible_paths' do
    let(:position) { build_position(area: 'Portugal', unit_type: unit_type) }

    context 'fleet' do
      let(:unit_type) { Position::FLEET }

      it 'takes into account coasts' do
        paths = subject.possible_paths(position, [])

        expect(summarize_paths(paths)).to eq([
          ['Mid Atlantic Ocean', nil],
          ['Spain', 'north'],
          ['Spain', 'south'],
        ])
      end
    end

    context 'army' do
      let(:unit_type) { Position::ARMY }

      it 'takes into account convoys' do
        mao_fleet_position = build_position(area: 'Mid Atlantic Ocean', unit_type: Position::FLEET)
        na_fleet_position = build_position(area: 'North Atlantic Ocean', unit_type: Position::FLEET)

        paths = subject.possible_paths(position, [mao_fleet_position, na_fleet_position])

        expect(summarize_paths(paths)).to eq(['Brest', 'Clyde', 'Gascony', 'Liverpool', 'North Africa', 'Spain'])
      end
    end
  end

  def summarize_paths(paths)
    paths.map do |path_segments|
      destination = path_segments.last
      destination.is_a?(Array) ? [destination.first.name, destination.last&.direction] : destination.name
    end.uniq.sort
  end
end

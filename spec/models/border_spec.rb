require 'rails_helper'

describe 'Border' do
  specify '#coastal?' do
    berlin = Area.find_by_name('Berlin')
    prussia = Area.find_by_name('Prussia')
    silesia = Area.find_by_name('Silesia')
    baltic_sea = Area.find_by_name('Baltic Sea')

    expect(berlin.borders.find_by(neighbor: prussia).coastal?).to be true
    expect(prussia.borders.find_by(neighbor: berlin).coastal?).to be true
    expect(berlin.borders.find_by(neighbor: baltic_sea).coastal?).to be false
    expect(berlin.borders.find_by(neighbor: silesia).coastal?).to be false
  end
end

require 'rails_helper'

describe 'Area' do
  specify '#coastal?' do
    expect(Area.find_by_name('Spain').coastal?).to be true
    expect(Area.find_by_name('Moscow').coastal?).to be false
    expect(Area.find_by_name('North Sea').coastal?).to be false
  end
end

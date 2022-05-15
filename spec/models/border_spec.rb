require 'rails_helper'

describe 'Border' do
  specify '#coastal?' do
    coastal1_area = create(:area, :land)
    coastal2_area = create(:area, :land)
    sea_area = create(:area, :sea)
    land_locked_area = create(:area, :land)

    land_locked_border = create(:border, area: land_locked_area, neighbor: coastal1_area)
    create(:border, area: coastal1_area, neighbor: land_locked_area)
    sea_border = create(:border, area: sea_area, neighbor: coastal1_area)
    create(:border, area: coastal1_area, neighbor: sea_area)
    create(:border, area: sea_area, neighbor: coastal2_area)
    create(:border, area: coastal2_area, neighbor: sea_area)
    coastal1_border = create(:border, area: coastal1_area, neighbor: coastal2_area)
    coastal2_border = create(:border, area: coastal2_area, neighbor: coastal1_area)

    expect(coastal1_border.reload.coastal?).to be true
    expect(coastal2_border.reload.coastal?).to be true
    expect(sea_border.reload.coastal?).to be false
    expect(land_locked_border.reload.coastal?).to be false
  end
end

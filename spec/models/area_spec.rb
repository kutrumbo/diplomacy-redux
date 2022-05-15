require 'rails_helper'

describe 'Area' do
  specify '#coastal?' do
    coastal_area = create(:area, :land)
    sea_area = create(:area, :sea)
    land_locked_area = create(:area, :land)
    create(:border, area: land_locked_area, neighbor: coastal_area)
    create(:border, area: coastal_area, neighbor: land_locked_area)
    create(:border, area: sea_area, neighbor: coastal_area)
    create(:border, area: coastal_area, neighbor: sea_area)

    expect(coastal_area.reload.coastal?).to be true
    expect(land_locked_area.reload.coastal?).to be false
    expect(sea_area.reload.coastal?).to be false
  end
end

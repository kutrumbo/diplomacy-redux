class Border < ApplicationRecord
  belongs_to :area
  belongs_to :neighbor, class_name: 'Area'
  belongs_to :coast, optional: true

  def coastal?
    return false if (self.area.sea? || self.neighbor.sea?)
    self.area.neighbors.sea.to_a.intersection(self.neighbor.neighbors.sea).present?
  end
end

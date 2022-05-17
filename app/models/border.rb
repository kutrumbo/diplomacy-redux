class Border < ApplicationRecord
  belongs_to :area
  belongs_to :neighbor, class_name: 'Area'
  belongs_to :coast, optional: true
end

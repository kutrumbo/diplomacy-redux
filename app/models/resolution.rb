class Resolution < ApplicationRecord
  FAILED = 'failed'.freeze
  SUCCEEDED = 'succeeded'.freeze
  UNRESOLVED = 'unresolved'.freeze
  STATUSES = [
    FAILED,
    SUCCEEDED,
    UNRESOLVED,
  ].freeze

  belongs_to :order

  # UNRESOLVED is not a valid final status, so exclude from list
  validates_inclusion_of :status, in: [FAILED, SUCCEEDED]

  STATUSES.each do |status|
    define_method("#{status}?") do
      self.status == status
    end
  end
end

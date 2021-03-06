class Organization < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :profile

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

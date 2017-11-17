class Type1 < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  belongs_to :extraction_forms_projects_section, inverse_of: :type1s

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extractions_extraction_forms_projects_section, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  delegate :project, to: :extraction_forms_projects_section

  def name_and_description
    text = name
    text.concat " (#{ description })" if description.present?
    return text
  end
end

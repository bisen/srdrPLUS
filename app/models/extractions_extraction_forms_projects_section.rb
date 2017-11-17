class ExtractionsExtractionFormsProjectsSection < ApplicationRecord
  include SharedParanoiaMethods
  include SharedProcessTokenMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction,                        inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :link_to_type1, class_name: 'ExtractionsExtractionFormsProjectsSection',
    foreign_key: 'extractions_extraction_forms_projects_section_id',
    optional: true

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :type1s, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  def type1_ids=(tokens)
    tokens.map { |token|
      resource = self.extraction_forms_projects_section.type1s.build
      save_resource_name_with_token(resource, token)
    }
    super
    tokens.each do |token|
      type1_id = token.to_i
      unless type1_id.zero?
        type1 = Type1.find(type1_id)
        eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(extractions_extraction_forms_projects_section: self, type1: type1)
        eefpst1.update(name: type1.name)
        eefpst1.update(description: type1.description) if eefpst1.blank?
      end
    end
  end
end

class ResultStatisticSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_descriptive_statistics

  belongs_to :result_statistic_section_type,                                                    inverse_of: :result_statistic_sections
  belongs_to :subgroup, class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn', inverse_of: :result_statistic_sections

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :measures, through: :result_statistic_sections_measures, dependent: :destroy
  has_many :comparisons, dependent: :destroy
  has_many :comparates, through: :comparisons, dependent: :destroy
  has_many :extractions_extraction_forms_projects_sections_type1s, through: :comparates, :source => :comparable, :source_type => 'ExtractionsExtractionFormsProjectsSectionsType1'

  accepts_nested_attributes_for :comparisons, allow_destroy: true
  accepts_nested_attributes_for :comparates, allow_destroy: true
  private

    def create_default_descriptive_statistics
      if result_statistic_section_type == ResultStatisticSectionType.find_by(name: 'Descriptive Statistics')
        Measure.is_default.each do |m|

          # This ends up adding m twice to ResultStatisticSection.
          #measures << m

          # This one works correctly...only adds it once.
          result_statistic_sections_measures.create(measure: m)
        end
      end
    end
end

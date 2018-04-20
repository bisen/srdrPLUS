class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  def update_all
    self.project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        efps.questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              arms = [ nil ]
              eefps = self.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section: efps)
              eefps = ExtractionsExtractionFormsProjectsSection.where(
                { extraction: self, extraction_forms_projects_section: efps } ).first
              if efps.link_to_type1 != nil
                arms = ExtractionsExtractionFormsProjectsSectionsType1
                  .joins(:extractions_extraction_forms_projects_section)
                  .where(extractions_extraction_forms_projects_sections:
                        { extraction: self,
                          extraction_forms_projects_section: efps.link_to_type1 }
                       ).all
              end
              if [ 5, 9 ].include? qrc.question_row_column_type_id
                qrc.question_row_columns_question_row_column_options.
                  where(question_row_column_option_id: 1).each do |qrcqrco|
                  arms.each do |arm|
                    qrcf = QuestionRowColumnField.find_or_create_by(
                             question_row_column: qrc,
                             question_row_columns_question_row_column_option: qrcqrco )

                    eefps_qrcf =
                      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
                      .find_or_create_by(
                        extractions_extraction_forms_projects_sections_type1: arm,
                        extractions_extraction_forms_projects_section: eefps,
                        question_row_column_field: qrcf )
                    record = Record.find_or_create_by(recordable: eefps_qrcf)

                  end
                end
              else
                arms.each do |arm|
                   eefps_qrcf =
                    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.
                      find_or_create_by(
                      extractions_extraction_forms_projects_sections_type1: arm,
                      extractions_extraction_forms_projects_section: eefps,
                      question_row_column_field: qrc.question_row_columns_fields.first )
                    record = Record.find_or_create_by(recordable: eefps_qrcf)
                end
              end
            end
          end
        end
      end
    end
  end
end

class ExtractionsExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_section, only: [:update]

  # PATCH/PUT /extractions_extraction_forms_projects_sections/1
  # PATCH/PUT /extractions_extraction_forms_projects_sections/1.json
  def update
    respond_to do |format|
      if @extractions_extraction_forms_projects_section.update(extractions_extraction_forms_projects_section_params)
        format.html { redirect_to work_extraction_path(@extractions_extraction_forms_projects_section.extraction,
                                                       anchor: "panel-tab-#{ @extractions_extraction_forms_projects_section.id.to_s }"),
                                  notice: t('success') }
        format.json { render :show, status: :ok, location: @extractions_extraction_forms_projects_section }
      else
        format.html { redirect_to work_extraction_path(@extractions_extraction_forms_projects_section.extraction,
                                                       anchor: "panel-tab-#{ @extractions_extraction_forms_projects_section.id.to_s }"),
                                  alert: t('failure') }
        format.json { render json: @extractions_extraction_forms_projects_section.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extractions_extraction_forms_projects_section
      @extractions_extraction_forms_projects_section = ExtractionsExtractionFormsProjectsSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extractions_extraction_forms_projects_section_params
      params.require(:extractions_extraction_forms_projects_section)
        .permit(:extraction_id,
                :extraction_forms_projects_section_id,
                type1s_attributes: [:id, :name, :description])
    end
end

class ExtractionsController < ApplicationController
  before_action :set_project, only: [:new, :create]
  before_action :set_extraction, only: [:show, :edit, :update, :destroy, :work]

  # GET /extractions
  # GET /extractions.json
  def index
    @extractions = Extraction.includes(:projects_study,
                                       projects_users_role: [projects_user: [user: [:profile]]],
                                       extractions_key_questions_projects: [key_questions_project: [:key_question, extraction_forms_projects_section: [extraction_forms_project: [:extraction_form]]]]).all
  end

  # GET /extractions/1
  # GET /extractions/1.json
  def show
  end

  # GET /extractions/new
  def new
    @extraction = Extraction.new
  end

  # GET /extractions/1/edit
  def edit
  end

  # POST /extractions
  # POST /extractions.json
  def create
    @extraction = Extraction.new(extraction_params)

    respond_to do |format|
      if @extraction.save
        format.html { redirect_to project_extractions_url(@extraction.projects_users_role.projects_user.project), notice: 'Extraction was successfully created.' }
        format.json { render :show, status: :created, location: @extraction }
      else
        format.html { render :new }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extractions/1
  # PATCH/PUT /extractions/1.json
  def update
    respond_to do |format|
      if @extraction.update(extraction_params)
        format.html { redirect_to work_extraction_path(@extraction,
                                                       anchor: "panel-tab-#{ params[:extraction][:extraction_forms_projects_section_id] }"),
                                  notice: t('success') }
        format.json { render :show, status: :ok, location: @extraction }
      else
        format.html { render :edit }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extractions/1
  # DELETE /extractions/1.json
  def destroy
    @extraction.destroy
    respond_to do |format|
      format.html { redirect_to project_extractions_url(@extraction.extraction_forms_project.project), notice: 'Extraction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /extractions/1/work
  def work
    @extraction_forms_projects = Set.new
    @extraction.extractions_key_questions_projects.includes(key_questions_project: [extraction_forms_projects_section: [:extraction_forms_projects_section_type, :section, extraction_forms_project: [:extraction_form]]]).order(key_questions_project_id: :asc).each do |ekqp|
      if ekqp.key_questions_project.extraction_forms_projects_section
        @extraction_forms_projects << ekqp.key_questions_project.extraction_forms_projects_section.extraction_forms_project
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_extraction
      @extraction = Extraction.includes(key_questions_projects: [:key_question,
                                                                 extraction_forms_projects_section: [:extraction_forms_projects_section_type]])
                              .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_params
      params.require(:extraction).permit(:projects_study_id,
                                         :projects_users_role_id,
                                         extractions_key_questions_project_ids: [],
                                         key_questions_project_ids: [])
    end
end

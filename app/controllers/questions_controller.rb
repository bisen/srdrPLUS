class QuestionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:new, :create]
  before_action :set_question, only: [:edit, :update, :destroy, :add_column, :add_row,
                                      :dependencies, :toggle_dependency]
  #before_action :ensure_matrix_type, only: [:add_column, :add_row]

  # GET /extraction_forms_projects_sections/1/questions/new
  def new
    @question = @extraction_forms_projects_section.questions.new
  end

  # GET /extraction_forms_projects_sections/1/questions/edit
  def edit
  end

  # POST /extraction_forms_projects_section/1/questions
  # POST /extraction_forms_projects_section/1/questions.json
  def create
    @question = @extraction_forms_projects_section.questions.new(question_params)

    # !!! Check for params 'q_type' and build values based on the type.

    respond_to do |format|
      if @question.save
        format.html { redirect_to edit_question_path(@question),
                                                      notice: t('success') }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_patch_params)
        format.html { redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @question.extraction_forms_projects_section.id }"),
                                  notice: t('success') }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
                                                                    anchor: "panel-tab-#{ @question.extraction_forms_projects_section.id }"),
                                                                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  # POST /questions/1/add_row
  # POST /questions/1/add_row.json
  def add_row
    @question.question_rows.create

    # Newly created question_row_columns do not have their name field set.
    # This triggers after_save :ensure_matrix_column_headers callback in
    # question model to set the name field.
    @question.save

    redirect_to edit_question_path(@question), notice: t('success')
  end

  # POST /questions/1/add_column
  # POST /questions/1/add_column.json
  def add_column
    @question.question_rows.each do |qr|
      qr.question_row_columns.create!(question_row_column_type: QuestionRowColumnType.first)
    end

    redirect_to edit_question_path(@question), notice: t('success')
  end

  def dependencies
    @extraction_forms_projects_section = @question.extraction_forms_projects_section
  end

  def toggle_dependency
    @prerequisitable = params[:question][:prerequisitable_type].constantize.find(params[:question][:prerequisitable_id].to_i)
    @question.toggle_dependency(@prerequisitable)

    respond_to do |format|
      format.js
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
    end

    def set_question
      @question = Question.includes(question_rows: [
        { question_row_columns: [ :question_row_column_options, :question_row_column_fields] }])
          .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question)
        .permit(:name,
                :description,
                key_questions_project_ids: []
               )
    end

    def question_patch_params
      params.require(:question)
        .permit(:name,
                :description,
                key_questions_project_ids: [],
                question_rows_attributes: [:id, :name, question_row_columns_attributes:
                                           [:id, :question_row_column_type_id, :name, question_row_columns_question_row_column_options_attributes:
                                            [:id, :_destroy, :question_row_column_option_id, :name]]]
               )
    end

#    def ensure_matrix_type
#      redirect_to root_url, notice: 'Your action is not allowed' unless @question.question_type.name.include?('Matrix')
#    end
end

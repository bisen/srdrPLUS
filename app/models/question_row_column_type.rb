class QuestionRowColumnType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row_column_type
end

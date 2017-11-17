class CreateExtractionsExtractionFormsProjectsSectionsType1Rows < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_extraction_forms_projects_sections_type1_rows do |t|
      t.references :extractions_extraction_forms_projects_sections_type1, foreign_key: true, index: { name: 'index_eefpst1r_on_eefpst1_id' }
      t.string :name
      t.string :unit
      t.boolean :is_baseline, default: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extractions_extraction_forms_projects_sections_type1_rows, :deleted_at,                                                             name: 'index_eefpst1r_on_deleted_at'
    add_index :extractions_extraction_forms_projects_sections_type1_rows, [:extractions_extraction_forms_projects_sections_type1_id, :deleted_at], name: 'index_eefpst1r_on_eefpst1_id_deleted_at', where: 'deleted_at IS NULL'
  end
end

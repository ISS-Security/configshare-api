require 'sequel'

Sequel.migration do
  change do
    create_table(:configurations) do
      String :id, type: :uuid, primary_key: true
      foreign_key :project_id

      String :filename, null: false
      String :relative_path, null: false, default: ''

      # secure data - initialize as nil until data provided
      String :description_secure, text: true
      String :document_secure, text: true

      DateTime :created_at
      DateTime :updated_at

      unique [:project_id, :relative_path, :filename]
    end
  end
end

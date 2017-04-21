require 'json'
require 'base64'
require 'sequel'

require_relative '../lib/secure_db'

# Holds a full configuration file's information
class Configuration < Sequel::Model
  plugin :uuid, field: :id
  set_allowed_columns :filename, :relative_path, :description

  many_to_one :project

  plugin :timestamps, update_on_create: true

  def description=(desc_plain)
    self.description_secure = SecureDB.encrypt(desc_plain)
  end

  def description
    SecureDB.decrypt(description_secure)
  end

  def document=(doc_plain)
    self.document_secure = SecureDB.encrypt(doc_plain)
  end

  def document
    SecureDB.decrypt(document_secure)
  end

  def to_json(options = {})
    JSON({
           type: 'configuration',
           id: id,
           data: {
             name: filename,
             description: description
           }
         },
         options)
  end
end

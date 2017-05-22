require 'json'
require 'sequel'

# Holds a Project's information
class Project < Sequel::Model
  many_to_one :owner, class: :Account
  many_to_many :contributors,
               class: :Account, join_table: :accounts_projects,
               left_key: :project_id, right_key: :contributor_id
  one_to_many :configurations

  plugin :timestamps, update_on_create: true
  plugin :association_dependencies
  add_association_dependencies configurations: :destroy, contributors: :nullify

  def full_details
    { type: 'project',
      id: id,
      attributes: {
        name: name,
        repo_url: repo_url
      },
      relationships: relationships }
  end

  def to_json(options = {})
    JSON({  type: 'project',
            id: id,
            attributes: {
              name: name,
              repo_url: repo_url
            },
            relationships: {
              owner: owner,
              contributors: contributors
            }
          },
         options)
  end

  private

  def relationships
    {
      owner: owner,
      contributors: contributors,
      configurations: configurations
    }
  end
end

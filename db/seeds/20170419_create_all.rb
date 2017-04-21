Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, projects, configurations'
    create_accounts
    create_projects
    create_configurations
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ALL_ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
ALL_PROJ_INFO = YAML.load_file("#{DIR}/projects_seed.yml")
ALL_CONF_INFO = YAML.load_file("#{DIR}/configurations_seed.yml")

def create_accounts
  ALL_ACCOUNTS_INFO.each do |account_info|
    CreateAccount.call(account_info)
  end
end

def create_projects
  proj_info_each = ALL_PROJ_INFO.each
  accounts_cycle = Account.all.cycle
  loop do
    proj_info = proj_info_each.next
    account = accounts_cycle.next
    CreateProjectForOwner.call(owner_id: account.id, name: proj_info[:name],
                               repo_url: proj_info[:repo_url])
  end
end

def create_configurations
  conf_info_each = ALL_CONF_INFO.each
  projects_cycle = Project.all.cycle
  loop do
    conf_info = conf_info_each.next
    project = projects_cycle.next
    CreateConfigurationForProject.call(
      project: project, filename: conf_info[:filename],
      description: conf_info[:description], document: conf_info[:document]
    )
  end
end

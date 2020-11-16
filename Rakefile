# frozen_string_literal: true

require 'solidus_dev_support/rake_tasks'

SolidusDevSupport::RakeTasks.class_eval do
  def install_changelog_task
    require 'github_changelog_generator/task'

    source_code_uri = URI.parse(gemspec.metadata['source_code_uri'])
    user, project = source_code_uri.path.split("/", 3)[1..2]

    GitHubChangelogGenerator::RakeTask.new(:changelog) do |config|
      config.user = user || 'solidus-contrib'
      config.project = project || gemspec.name
      config.future_release = "v#{gemspec.version}"
    end
  end
end

SolidusDevSupport::RakeTasks.install

task default: 'extension:specs'

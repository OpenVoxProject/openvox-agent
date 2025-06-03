OPENVOX_AGENT_VERSION = "7.36.1"

def run_command(cmd)
  output, status = Open3.capture2e(cmd)
  abort "Command failed! Command: #{cmd}, Output: #{output}" unless status.exitstatus.zero?
  output.chomp
end

Dir.glob(File.join('tasks/**/*.rake')).each { |file| load file }

### Puppetlabs stuff ###
require 'packaging'

load './ext/release-lead.rake'

Pkg::Util::RakeUtils.load_packaging_tasks

desc 'run static analysis with rubocop'
task(:rubocop) do
  require 'rubocop'
  cli = RuboCop::CLI.new
  exit_code = cli.run(%w(--display-cop-names --format simple))
  raise "RuboCop detected offenses" if exit_code != 0
end

desc "verify that commit messages match CONTRIBUTING.md requirements"
task(:commits) do
  # This rake task looks at the summary from every commit from this branch not
  # in the branch targeted for a PR. This is accomplished by using the
  # TRAVIS_COMMIT_RANGE environment variable, which is present in travis CI and
  # populated with the range of commits the PR contains. If not available, this
  # falls back to `main..HEAD` as a next best bet as `main` is unlikely to
  # ever be absent.
  #
  # When we move to GH actions, use `GITHUB_BASE_REF` to resolve the merge base
  # ref, which is the common ancestor between the base branch and PR. Then do
  # git log for all of the commits in `HEAD` that are not in the base ref
  #
  #   baseref = %x{git merge-base HEAD $GITHUB_BASE_REF}
  #   commits = "#{baseref}..HEAD"
  commits = ENV['TRAVIS_COMMIT_RANGE'].nil? ? 'main..HEAD' : ENV['TRAVIS_COMMIT_RANGE'].sub(/\.\.\./, '..')
  %x{git log --no-merges --pretty=%s #{commits}}.each_line do |commit_summary|
    error_message=<<-HEREDOC
\n\n\n\tThis commit summary didn't match CONTRIBUTING.md guidelines:\n \
\n\t\t#{commit_summary}\n \
\tThe commit summary (i.e. the first line of the commit message) should start with one of:\n  \
\t\t(docs)\n \
\t\t(maint)\n \
\t\t(packaging)\n \
\t\t(<ANY PUBLIC JIRA TICKET>)\n \
\n\tThis test for the commit summary is case-insensitive.\n\n\n
    HEREDOC

    if /^\((maint|doc|docs|packaging|pa-\d+)\)|revert|bumping|merge|promoting/i.match(commit_summary).nil?
      ticket = commit_summary.match(/^\(([[:alpha:]]+-[[:digit:]]+)\).*/)
      if ticket.nil?
        raise error_message
      else
        require 'net/http'
        require 'uri'
        uri = URI.parse("https://tickets.puppetlabs.com/browse/#{ticket[1]}")
        response = Net::HTTP.get_response(uri)
        if response.code != "200"
          raise error_message
        end
      end
    end
  end
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = <<~HEADER.chomp
    # Changelog
    All notable changes to this project will be documented in this file.
    HEADER
    config.user = "openvoxproject"
    config.project = "openvox-agent"
    config.exclude_labels = %w[dependencies duplicate question invalid wontfix wont-fix modulesync skip-changelog]
    config.future_release = OPENVOX_AGENT_VERSION
    # FIXME: The following should be enough to ignore versions in the main
    # branch only, but this does not work.  For now we rely on a regexp to
    # exclude tags that should not be matched.
    config.release_branch = "7.x"
    config.exclude_tags_regex = /\A8\./
  end
rescue LoadError
  task :changelog do
    abort("Run `bundle install --with packaging` to install the `github_changelog_generator` gem.")
  end
end

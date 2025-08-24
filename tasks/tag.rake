namespace :vox do
  desc 'Create tag and push to origin'
  task :tag, [:tag] do |_, args|
    abort 'You must provide a tag.' if args[:tag].nil? || args[:tag].empty?
    version = args[:tag]
    abort "#{version} does not appear to be a valid version string in x.y.z format" unless Gem::Version.correct?(version)

    # Changed unreleased to new version in CHANGELOG.md
    ENV['OPENVOX_AGENT_VERSION'] = version
    puts 'Updating CHANGELOG.md'
    Rake::Task['changelog'].invoke
    run_command("git add CHANGELOG.md && git commit -m 'Update changelog for #{version}'")

    # Run git command to get short SHA and one line description of the commit on HEAD
    branch = run_command('git rev-parse --abbrev-ref HEAD')
    sha = run_command('git rev-parse --short HEAD')
    msg = run_command('git log -n 1 --pretty=%B')

    puts "Branch: #{branch}"
    puts "SHA: #{sha}"
    puts "Commit: #{msg}"

    run_command("git tag -a #{version} -m '#{version}'")

    if ENV['NOPUSH'].nil?
      puts "Pushing to origin"
      run_command("git push origin && git push origin #{version}")
    end
  end
end

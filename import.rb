# frozen_string_literal: true

require "bundler/inline"
require "pp"

gemfile do
  source "https://rubygems.org"

  gem "activesupport", require: "active_support/core_ext/hash/except"
  gem "esa"
end

# ref: https://docs.esa.io/posts/102
class Importer
  attr_reader :client, :file_names

  def initialize(client, dirpath)
    @client  = client
    Dir.chdir(dirpath)
    @file_names = Dir.glob("**/*.md")
  end

  def import(dry_run: true)
    file_names.each do |file_name|
      title = title_from_heading(file_name)
      original_category = File.dirname(file_name)
      params = {
        name:     title,
        category: "Imports/DPaper/" + original_category,
        body_md:  File.read(file_name),
        wip:      false,
        message:  "[skip notice] Imported from Dropbox Paper",
        user:     "esa_bot",
      }

      if dry_run?(dry_run)
        pp params.except(:body_md)
        puts
        next
      end

      print "[#{Time.now}] #{title} => "
      response = client.create_post(params)
      case response.status
      when 201
        puts "created: #{response.body["full_name"]}"
      when 429
        retry_after = (response.headers['Retry-After'] || 20 * 60).to_i
        puts "rate limit exceeded: will retry after #{retry_after} seconds."
        wait_for(retry_after)
        redo
      else
        puts "failure with status: #{response.status}"
        exit 1
      end
    end
  end

  private

  def dry_run?(flag)
    flag = flag.to_s.downcase
    flag.match?(/^(1|t|y)/)
  end

  def title_from_heading(file_name)
    File.readlines(file_name)[0].tr("# ", "").chomp
  end

  def wait_for(seconds)
    (seconds / 10).times do
      print "."
      sleep 10
    end
    puts
  end
end

client = Esa::Client.new(
  access_token: ENV.fetch("ACCESS_TOKEN"),
  current_team: ENV.fetch("TEAM_NAME"),
)
importer = Importer.new(client, "docs")
importer.import(dry_run: ENV["DRY_RUN"])

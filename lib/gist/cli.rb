require 'rubygems'
require 'commander/import'
require 'terminal-table/import'
require 'gist/api'

class Gist::CLI
  def initialize
    @user = `git config --global github.user`.strip
    @token = `git config --global github.token`.strip
  end

  def execute
    program :name, 'gist'
    program :version, Gist::VERSION
    program :description, 'Command-line interface for http://gist.github.com'
    program :help_formatter, :compact

    default_command :help

    global_option '--user USER', String, "GitHub user name" do |value|
      @user = value
    end

    global_option '--token TOKEN', String, "GitHub API token" do |value|
      @token = value
    end

    command :clone do |c|
      c.syntax = 'clone ID'
      c.description = 'Clones the specified gist into the current folder'
      c.when_called do |args, options|
        system("git clone #{Gist::API.gist_url(args.first, :git)}")
      end
    end

    command :delete do |c|
      c.syntax = 'delete ID'
      c.description = 'Deletes the specified gist'
      c.when_called do |args, options|
        require_username
        require_token
        raise "No ID specified" unless args.any?
        Gist::API.delete_gist(args.first, { :login => @user, :token => @token })
      end
    end

    command :list do |c|
      c.syntax = 'list [--all]'
      c.description = 'Lists gists'
      c.example "List public gists from knoopx", 'list --user knoopx'
      c.option '--all', 'Lists all gists including private ones. User and token should be specified'
      c.when_called do |args, options|
        require_username
        opts = {}
        if options.all
          require_token
          opts[:login] = @user
          opts[:token] = @token
        end
        puts gist_table(Gist::API.list_gists(@user, opts))
      end
    end

    command :create do |c|
      c.syntax = 'create FILE [--private] [--anonymous]'
      c.example "Create a private gist from file example.rb", 'create example.rb --private'
      c.description = 'Create a new gist'
      c.option '--description DESCRIPTION', String, "Gist description"
      c.option '--private', 'Create a private gist'
      c.option '--anonymous', 'Create anonymous gist'
      c.when_called do |args, options|
        raise "No files specified" unless args.any?
        opts = {}
        opts[:private] = true if options.private
        opts[:login] = @user if @user and not options.anonymous
        opts[:token] = @token if @token and not options.anonymous
        opts[:description] = options.description if options.description
        puts gist_table(Gist::API.post_gist(args, opts))
      end
    end

    command :print do |c|
      c.syntax = 'print ID'
      c.description = 'Prints the contents of the specified gist'
      c.when_called do |args, options|
        raise "No ID specified" unless args.any?
        puts Gist::API.get_gist(args.first)
      end
    end
  end

  protected

  def require_username
    raise "GitHub user not found, please configure git with your GitHub credentials" if @user.empty?
  end

  def require_token
    raise "GitHub token not found, please configure git with your GitHub credentials or specify" if @token.empty?
  end

  def gist_table (gists)
    if gists.any?
      table do |t|
        t.headings = "Id", "Description", "Date", "Privacity", "URL"
        gists.each do |gist|
          t << [gist.id, gist.description, gist.created_at, gist.privacity, Gist::API::gist_url(gist.id)]
        end
      end
    else
      "No gists to list."
    end
  end
end
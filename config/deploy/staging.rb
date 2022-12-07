set :branch, ENV["branch"] || :stable

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]

require "yaml"

module Serif
class Config
  def initialize(config_file)
    @config_file = config_file
  end

  def yaml
    YAML.load_file(@config_file)
  end

  def admin_username
    yaml["admin"]["username"]
  end

  def admin_password
    yaml["admin"]["password"]
  end

  def permalink
    yaml["permalink"] || "/:title"
  end
end
end
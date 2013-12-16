module Auth
  class Credentials
    attr_accessor :credentials

    def method_missing(selector)
      retrieve_value(parse_method(selector)) || super
    end

    def respond_to_missing?(selector, *)
      !!retrieve_value(parse_method(selector))
    end

    # in the kitchen

    def credentials
      @credentials ||= load_credentials
    end

    def load_credentials
      env_file = File.join("config", "env.yml")
      File.exists?(env_file) ? YAML::load(File.open(env_file))["CREDENTIALS"] : false
    end

    def retrieve_value(key)
      credentials ? credentials[key] : ENV[key]
    end

    def parse_method(method)
      method.to_s.upcase
    end
  end
end

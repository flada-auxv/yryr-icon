class Icon
  attr_accessor :url, :file

  class << self
    def all_urls
      @all_urls ||= YAML.load_file('./config/image_urls.yml')
    end

    def random_url
      all_urls.sample
    end

    def get(url)
      begin
        res = client.get(url)
      rescue Faraday::ResourceNotFound, Faraday::ConnectionFailed
        return nil
      end

      return nil unless %w(image/jpeg image/png).include?(res.headers[:content_type])

      file = create_tempfile(res.body)

      new(url: url, file: create_tempfile(res.body))
    end

    def get_random
      get(random_url)
    end

    def create_tempfile(str)
      tempfile = Tempfile.create(['yryr_icon', '.jpg'])
      tempfile.write(str)
      tempfile.rewind
      tempfile
    end

    private

    def client
      Faraday.new {|faraday|
        faraday.request  :url_encoded
        faraday.response :logger
        faraday.adapter  Faraday.default_adapter
      }
    end
  end

  def initialize(attributes = {})
    @url = attributes[:url]
    @file = attributes[:file]
  end
end

class YRYRIcon
  attr_accessor :url, :file

  class << self
    def all_urls
      @all_urls ||= YAML.load_file('./config/image_urls.yml')
    end

    def random_url
      all_urls.sample
    end

    def get_random_icon
      url = random_url
      res = client.get(url)

      tempfile = Tempfile.create(['yryr_icon', '.jpg'])
      tempfile.write(res.body)
      tempfile.rewind
      tempfile

      new {|icon|
        icon.url = url
        icon.file = tempfile
      }
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

  def initialize(&block)
    yield(self) if block_given?
  end
end

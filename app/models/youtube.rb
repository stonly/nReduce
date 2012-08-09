class Youtube < Video
  # Pass in a url string
  # Formats:
  # http://www.youtube.com/watch?feature=player_embedded&v=2f70gxTUt5U
  # http://youtu.be/2f70gxTUt5U
  # http://www.youtube.com/embed/2f70gxTUt5U
  # and this will return the video id: 2f70gxTUt5U
  def self.id_from_url(url_string)
    begin
      uri = URI.parse(url_string)
      if uri.host == 'youtu.be' # url shortener version
        uri.path.sub(/^\//, '')
      elsif uri.path.match('embed') != nil # embed version
        uri.path.match(/[a-zA-Z0-9]*$/)[0]
      elsif uri.host.match('youtube.com') != nil # regular web url
        Hash[URI.decode_www_form(uri.query)]['v']
      else
        nil
      end
    rescue
      nil
    end
  end
  
    # Pass in a url string, and it will return the embed url
  def self.embed_url(url_string)
    id = Youtube.id_from_url(url_string)
    return '' if id.blank?
    Youtube.embed_url_for_id(id)
  end

   # Returns url string that can be used as iframe source to embed video
  def self.embed_url_for_id(id)
    # add &rel=0 so related videos aren't shown
    "http://www.youtube.com/embed/#{id}?rel=0"
  end

  def self.valid_url?(url_string)
    return !Youtube.embed_url(url_string).blank?
  end

  # Creates new Youtube object from Youtube url string
  def self.create_from_url(url_string)
    id = self.id_from_url(url_string)
    v = Youtube.new
    unless id.blank?
      v.external_id = id 
      v.save
    end
    v
  end

  def embed_url
    Youtube.embed_url_for_id(self.external_id)
  end

  # Generates download link from external id and then triggers super method to save video locally
  def save_external_video_locally
    # First we have to get the token from youtube to download the video
    uri = URI.parse('http://www.youtube.com/get_video_info?&video_id=' + self.external_id)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    body = CGI::parse(response.body) unless response.body.blank?
    token = body['token'].first unless body.blank?
    raise "Youtube: could not get token for video with id #{self.external_id}" if token.blank?
    # Now we can get the video
    # Youtube quality formats: http://en.wikipedia.org/wiki/Youtube#Quality_and_codecs
    # fmt=18 is mp4 360p
    # fmt=22 is mp4 720p

    url = "http://www.youtube.com/get_video?video_id=#{self.external_id}&t=#{token}&fmt=18&l=#{body['l'].first}&sk=#{body['sk'].first}"

    uri = URI.parse(url)
    puts url
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    puts response.inspect
    rh = CGI::parse(response)
    rh.each do |k,v|
      puts "#{k} -- #{v}"
    end
    return
    self.save_file_locally("http://www.youtube.com/get_video?video_id=#{self.external_id}&t=#{token}&fmt=18", 'mp4')
    puts self.local_file_path
    return

    uri = URI.parse(Youtube.download_url_for_id(self.external_id))
    http = Net::HTTP.new(uri.host, uri.port)
    FileUtils.touch '/Users/josh/Projects/nreduce/tmp/video/sample.flv'
    open('/Users/josh/Projects/nreduce/tmp/video/sample.flv')
    http.request_get(uri.path) do |resp|
      resp.read_body do |segment|
        f.write(segment)
      end
    end
    f.close
    return


    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    puts response.inspect
    self.save_file_locally(Youtube.download_url_for_id(self.external_id), 'flv')
  end
end
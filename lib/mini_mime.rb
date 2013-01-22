class MiniMime
  
  def initialize
    @split = "----=_Part_0_#{((rand*10000000) + 10000000).to_i}.#{((Time.new.to_f) * 1000).to_i}"
    @contents = []
  end
  
  def add_content(configs)
    result = "Content-Type: #{configs[:type]}"
    # Set hte Content-ID header
    if @contents.length == 0 && !configs[:content_id]
      result += "\nContent-ID: <part0@sencha.com>"
    else
      content_id = configs[:content_id]
      content_id = "<part#{@contents.length + 1}@sencha.com>" unless content_id
      result += "\nContent-ID: #{content_id}"
    end
    if configs[:headers]
      for k,v in configs[:headers]
        result += "\n#{k}: #{v}"
      end
    end
    result += "\n\n#{configs[:content]}"
    result += "\n" unless configs[:content][-1] == "\n"
    @contents << result
  end
  
  def header
    'multipart/related; type="text/xml"; start="<part0@sencha.com>"; boundary="' + @split + '"'
  end
  
  def content
    "--#{@split}\n" + @contents.join("--#{@split}\n") + "--#{@split}--\n"
  end
  
end
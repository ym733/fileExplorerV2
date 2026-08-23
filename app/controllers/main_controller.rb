class MainController < ApplicationController
  before_action :check_session_expiration

  private def check_session_expiration
    if (not session[:last_seen_at]) || session[:last_seen_at] < 2.hours.ago
      redirect_to access_denied_path
    end
  end

  def index
    @root_directory_path = Dir.home

    flash[:current_path] = @root_directory_path
  end

  def refresh_file
    unless request.headers["Turbo-Frame"].present?
      redirect_to root_path
      return
    end

    path = flash[:current_path]

    puts "PATH: #{path}"

    if File.directory?(path)
      @item_path = path
      directory_tree = directory_tree(@item_path)
      @is_empty = directory_tree.empty?
      @children = []

      unless @is_empty
        directory_tree.each do |child|
          @children << { name: child[:name], item_path: child[:item_path], type: child[:type] }
        end
      end

      flash[:current_path] = @item_path
      render partial: "folder_view", status: :ok

    else
      @is_text = text_file?(path)
      @extension = File.extname(path).delete_prefix(".").downcase

      if @extension == ""
        @extension = File.basename(path).downcase
      end

      @item_path = path

      if @is_text
        @text = File.read(path)

        @language = prog_language(@extension)
      end

      image_extensions = %w[png jpg jpeg gif webp svg bmp ico]
      if image_extensions.include?(@extension.downcase)
        @image = Base64.strict_encode64(File.read(@item_path, binmode: true))
      end

      video_extensions = %w[mp4 mov webm ogg m4v]
      @is_video = video_extensions.include?(@extension.downcase)

      flash[:current_path] = @item_path
      render partial: "file_grid", status: :ok
    end
  end

  def file
    unless request.headers["Turbo-Frame"].present?
      redirect_to root_path
      return
    end

    @is_text = text_file?(params[:item_path])
    @extension = File.extname(params[:item_path]).delete_prefix(".").downcase

    if @extension == ""
      @extension = File.basename(params[:item_path]).downcase
    end

    @item_path = params[:item_path]

    if @is_text
      @text = File.read(params[:item_path])

      @language = prog_language(@extension)
    end

    image_extensions = %w[png jpg jpeg gif webp svg bmp ico]
    if image_extensions.include?(@extension.downcase)
      @image = Base64.strict_encode64(File.read(@item_path, binmode: true))
    end

    video_extensions = %w[mp4 mov webm ogg m4v]
    @is_video = video_extensions.include?(@extension.downcase)

    flash[:current_path] = @item_path
    render partial: "file_grid", status: :ok
  end

  def folder
    unless params[:item_path]
      redirect_to root_path
      return
    end

    @item_path = params[:item_path]
    directory_tree = directory_tree(@item_path)
    @is_empty = directory_tree.empty?
    @children = []


    unless @is_empty
      directory_tree.each do |child|
        @children << { name: child[:name], item_path: child[:item_path], type: child[:type] }
      end
    end

    flash[:current_path] = @item_path
    render partial: "folder_view", status: :ok
  end

  def save
    unless request.xhr?
      redirect_to root_path
      return
    end

    text_data = params[:'text_data']
    item_path = params[:'item_path']

    if text_data.blank? || item_path.blank?
      return render json: { error: "Error! Both 'text-data' and 'item-path' are required" }, status: :bad_request
    end

    begin
      File.write(item_path, text_data)
      render json: {  result: "Success!", message: "'#{item_path.split("/")[-1]}' saved successfully!" }, status: :ok
    rescue => e
      render json: { error: "Error! #{e.message}" }, status: :unprocessable_entity
    end
  end

  def back
    unless request.headers["Turbo-Frame"].present?
      redirect_to root_path
      return
    end

    unless flash[:current_path] == Dir.home
      params[:item_path] = (flash[:current_path].split("/")[0...-1]).join("/")
    else
      params[:item_path] = Dir.home
    end

    folder()
  end

  def new_file
    current_path = flash[:current_path]
    item_type = params[:'item_type']
    item_name = params[:'name']

    if item_type == "folder"

      if Dir.exist?("#{current_path}/#{item_name}")
        count = 1
        loop do
          break unless Dir.exist?("#{current_path}/#{item_name} (#{count})")
          count += 1
        end

        item_name = "#{item_name} (#{count})"
      end

      Dir.mkdir(File.join(current_path, item_name))
    else
      if File.exist?("#{current_path}/#{item_name}")
        count = 1
        name = File.basename(item_name, File.extname(item_name))
        extension = File.extname(item_name)

        loop do
          break unless File.exist?("#{current_path}/#{name} (#{count})#{extension}")
          count += 1
        end

        item_name = "#{name} (#{count})#{extension}"
      end

      File.write(File.join(current_path, item_name), "")
    end

    params[:item_path] = current_path
    folder()
  end

  def upload
    unless request.xhr?
      redirect_to root_path
      return
    end

    current_path = flash[:current_path]

    if params[:file].present?
      uploaded_file = params[:file]

      file_name = uploaded_file.original_filename
      file_content = uploaded_file.read

      if File.exist?("#{current_path}/#{file_name}")
        count = 1
        name = File.basename(file_name, File.extname(file_name))
        extension = File.extname(file_name)

        loop do
          break unless File.exist?("#{current_path}/#{name} (#{count})#{extension}")
          count += 1
        end

        file_name = "#{name} (#{count})#{extension}"
      end

      File.open(File.join(current_path, file_name), "wb") do |file|
        file.write(file_content)
      end
    end

    params[:item_path] = current_path
    folder()
  end

  def delete_file
    current_path = flash[:current_path]
    item_path = params[:item_path]

    unless File.exist? item_path
      render json: { error: "File does not exist" }, status: :bad_request
    end

    File.delete(item_path)

    params[:item_path] = current_path
    folder()
  end

  def download_file
    unless params[:file_path]
      redirect_to root_path
      return
    end

    file_path = params[:file_path]

    send_file(
      file_path,
      filename: File.basename(file_path),
      disposition: "attachment"
    )
  end

  def children
    unless request.xhr?
      redirect_to root_path
      return
    end

    item_path = params[:item_path]
    children_parsed = directory_tree(item_path)

    render partial: "shared/directory_tree", locals: { tree: children_parsed }
  end

  #==============================================================
  # BELLOW ARE TOOLS AND NOT ROUTES
  #==============================================================
  def stream
    unless params[:item_path]
      redirect_to root_path
      return
    end

    item_path = params[:item_path]
    extension = File.extname(item_path).delete_prefix(".").downcase

    file_size = File.size(item_path)
    content_type = Rack::Mime.mime_type(".#{extension}", "video/mp4")
    range_header = request.headers["Range"]

    response.headers["Accept-Ranges"] = "bytes"
    response.headers["Content-Type"] = content_type

    if range_header
      match = range_header.match(/bytes=(\d*)-(\d*)/)
      range_start = match[1].to_s.empty? ? 0 : match[1].to_i
      range_end = match[2].to_s.empty? ? file_size - 1 : match[2].to_i
      range_end = file_size - 1 if range_end > file_size - 1
      length = range_end - range_start + 1

      response.status = :partial_content
      response.headers["Content-Range"] = "bytes #{range_start}-#{range_end}/#{file_size}"
      response.headers["Content-Length"] = length.to_s

      self.response_body = Enumerator.new do |yielder|
        File.open(item_path, "rb") do |f|
          f.seek(range_start)
          remaining = length
          while remaining > 0
            chunk = f.read([ 1.megabyte, remaining ].min)
            break unless chunk
            yielder << chunk
            remaining -= chunk.bytesize
          end
        end
      end
    else
      response.headers["Content-Length"] = file_size.to_s
      self.response_body = Enumerator.new do |yielder|
        File.open(item_path, "rb") do |f|
          yielder << chunk while (chunk = f.read(1.megabyte))
        end
      end
    end
  end

  private

  def directory_tree(path)
    items = []
    Dir.foreach(path) do |item|
      item_path = File.join(path, item)
      next if item[0] == '.' && File.directory?(item_path) # rubocop:disable Style/StringLiterals

      items << {
        name: item,
        item_path: item_path,
        type: File.directory?(item_path) ? "directory" : "file"
      }
    end
    items.sort_by { |item| item[:name].downcase }
  end

  # Function to tell if the file accessed is a binary or a text file
  def text_file?(path, blocksize: 512)
    return false unless File.exist?(path)
    return false if File.directory?(path)

    File.open(path, "rb") do |f|
      chunk = f.read(blocksize)

      return true if chunk.nil? || chunk.empty? # empty files → treat as text

      # Check for null bytes (common in binary files)
      return false if chunk.include?("\x00")

      # Count non-printable characters
      printable = chunk.count("\x09\x0A\x0D" + (32..126).map(&:chr).join)

      ratio = printable.to_f / chunk.size
      return ratio > 0.7 # if ≥ 70% printable → text
    end
  end

  def prog_language(ext)
    lang_map = {
      "apl" => {
        "extensions" => [ "apl", "dyalog", "aplf", "apln", "aplc", "aplo" ],
        "mode" => "text/apl",
        "file" => [ "apl.js" ]
      },
      "asp" => {
        "extensions" => [ "aspx" ],
        "mode" => "application/x-aspx",
        "file" => [ "clike.js", "xml.js", "css.js", "javascript.js", "html.js", "htmlembedded.js" ]
      },
      "brainfuck" => {
        "extensions" => [ "bf", "bfk", "brainfuck" ],
        "mode" => "text/x-brainfuck",
        "file" => [ "brainfuck.js" ]
      },
      "c" => {
        "extensions" => [ "c", "h" ],
        "mode" => "text/x-csrc",
        "file" => [ "clike.js" ]
      },
      "c++" => {
        "extensions" => [ "cpp", "hpp", "cc", "hh", "c++", "h++" ],
        "mode" => "text/x-c++src",
        "file" => [ "clike.js" ]
      },
      "c#" => {
        "extensions" => [ "csharp", "cs" ],
        "mode" => "text/x-csharp",
        "file" => [ "clike.js" ]
      },
      "cmake" => {
        "extensions" => [ "cmake" ],
        "mode" => "text/x-cmake",
        "file" => [ "cmake.js" ]
      },
      "cobol" => {
        "extensions" => [ "cob", "cbl", "cpy", "cobol" ],
        "mode" => "text/x-cobol",
        "file" => [ "cobol.js" ]
      },
      "css" => {
        "extensions" => [ "css" ],
        "mode" => "text/css",
        "file" => [ "css.js" ]
      },
      "dart" => {
        "extensions" => [ "dart" ],
        "mode" => "application/dart",
        "file" => [ "clike.js", "dart.js" ]
      },
      "dockerfile" => {
        "extensions" => [ "dockerfile", "df", "dock", "docker" ],
        "mode" => "text/x-dockerfile",
        "file" => [ "dockerfile.js" ]
      },
      "ejs" => {
        "extensions" => [ "ejs" ],
        "mode" => "application/x-ejs",
        "file" => [ "xml.js", "css.js", "javascript.js", "html.js", "htmlembedded.js" ]
      },
      "erb" => {
        "extensions" => [ "erb" ],
        "mode" => "application/x-erb",
        "file" => [ "ruby.js", "xml.js", "css.js", "javascript.js", "html.js", "htmlembedded.js" ]
      },
      "erlang" => {
        "extensions" => [ "erlang", "erl" ],
        "mode" => "text/x-erlang",
        "file" => [ "erlang.js" ]
      },
      "fortran" => {
        "extensions" => [ "fortran", "f90", "f95" ],
        "mode" => "text/x-fortran",
        "file" => [ "fortran.js" ]
      },
      "go" => {
        "extensions" => [ "go", "golang" ],
        "mode" => "text/x-go",
        "file" => [ "go.js" ]
      },
      "groovy" => {
        "extensions" => [ "groovy" ],
        "mode" => "text/x-groovy",
        "file" => [ "groovy.js" ]
      },
      "haskell" => {
        "extensions" => [ "haskell", "hs" ],
        "mode" => "text/x-haskell",
        "file" => [ "haskell.js" ]
      },
      "htmlmixed" => {
        "extensions" => [ "htm", "html" ],
        "mode" => "text/html",
        "file" => [ "html.js", "xml.js", "javascript.js", "css.js" ]
      },
      "http" => {
        "extensions" => [ "http", "https" ],
        "mode" => "message/http",
        "file" => [ "http.js" ]
      },
      "java" => {
        "extensions" => [ "java" ],
        "mode" => "text/x-java",
        "file" => [ "clike.js" ]
      },
      "javascript" => {
        "extensions" => [ "js", "mjs", "cjs" ],
        "mode" => "text/javascript",
        "file" => [ "javascript.js" ]
      },
      "json" => {
        "extensions" => [ "json" ],
        "mode" => "application/json",
        "file" => [ "javascript.js" ]
      },
      "jsp" => {
        "extensions" => [ "jsp" ],
        "mode" => "application/x-jsp",
        "file" => [ "clike.js", "xml.js", "css.js", "javascript.js", "html.js", "htmlembedded.js" ]
      },
      "jsx" => {
        "extensions" => [ "jsx", "tsx" ],
        "mode" => "text/jsx",
        "file" => [ "jsx.js", "xml.js", "javascript.js" ]
      },
      "julia" => {
        "extensions" => [ "julia", "jl" ],
        "mode" => "text/x-julia",
        "file" => [ "julia.js" ]
      },
      "lua" => {
        "extensions" => [ "lua" ],
        "mode" => "text/x-lua",
        "file" => [ "lua.js" ]
      },
      "markdown" => {
        "extensions" => [ "markdown", "md", "mkdown", "mkd" ],
        "mode" => "text/x-markdown",
        "file" => [ "markdown.js", "xml.js" ]
      },
      "nginx" => {
        "extensions" => [ "nginx", "nginxconf" ],
        "mode" => "text/x-nginx-conf",
        "file" => [ "nginx.js" ]
      },
      "objective-c" => {
        "extensions" => [ "objectivec", "mm", "objc", "obj-c" ],
        "mode" => "text/x-objectivec",
        "file" => [ "clike.js" ]
      },
      "pascal" => {
        "extensions" => [ "pas" ],
        "mode" => "text/x-pascal",
        "file" => [ "pascal.js" ]
      },
      "perl" => {
        "extensions" => [ "perl", "pl", "pm" ],
        "mode" => "text/x-perl",
        "file" => [ "perl.js" ]
      },
      "php" => {
        "extensions" => [ "php" ],
        "mode" => "text/x-php",
        "file" => [ "php.js", "html.js", "clike.js" ]
      },
      "powershell" => {
        "extensions" => [ "powershell", "ps" ],
        "mode" => "application/x-powershell",
        "file" => [ "powershell.js" ]
      },
      "python" => {
        "extensions" => [ "python", "py" ],
        "mode" => "text/x-python",
        "file" => [ "python.js" ]
      },
      "r" => {
        "extensions" => [ "r" ],
        "mode" => "text/x-rsrc",
        "file" => [ "r.js" ]
      },
      "ruby" => {
        "extensions" => [ "ruby", "rb", "gemspec", "podspec", "irb" ],
        "mode" => "text/x-ruby",
        "file" => [ "ruby.js" ]
      },
      "rust" => {
        "extensions" => [ "rust", "rs" ],
        "mode" => "text/x-rustsrc",
        "file" => [ "rust.js" ]
      },
      "sass" => {
        "extensions" => [ "sass" ],
        "mode" => "text/x-sass",
        "file" => [ "sass.js", "css.js" ]
      },
      "scala" => {
        "extensions" => [ "sc", "scala" ],
        "mode" => "text/x-scala",
        "file" => [ "clike.js" ]
      },
      "scss" => {
        "extensions" => [ "scss" ],
        "mode" => "text/x-scss",
        "file" => [ "css.js" ]
      },
      "shell" => {
        "extensions" => [ "shell", "console", "bash", "sh", "zsh" ],
        "mode" => "text/x-sh",
        "file" => [ "shell.js" ]
      },
      "sql" => {
        "extensions" => [ "sql" ],
        "mode" => "text/x-sql",
        "file" => [ "sql.js" ]
      },
      "swift" => {
        "extensions" => [ "swift" ],
        "mode" => "text/x-swift",
        "file" => [ "swift.js" ]
      },
      "typescript" => {
        "extensions" => [ "ts" ],
        "mode" => "text/typescript",
        "file" => [ "javascript.js" ]
      },
      "xml" => {
        "extensions" => [ "xml", "xlam", "xps" ],
        "mode" => "application/xml",
        "file" => [ "xml.js" ]
      },
      "yaml" => {
        "extensions" => [ "yml", "yaml" ],
        "mode" => "text/x-yaml",
        "file" => [ "yaml.js" ]
      }
    }
    lang_map.each do |lang, data|
      if data["extensions"].include?(ext)
        return {
          language: lang,
          mode: data["mode"],
          files: data["file"]
        }
      end
    end
    # Return nil if no match found
    {
      language: "text",
      mode: "",
      files: []
    }
  end
end

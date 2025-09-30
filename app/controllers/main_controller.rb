class MainController < ApplicationController
  def index
    root_directory_path = Dir.home

    def build_directory_tree(path)
      items = []
      Dir.foreach(path) do |item|
        item_path = File.join(path, item)
        next if item[0] == '.' && File.directory?(item_path) # rubocop:disable Style/StringLiterals

        if File.directory?(item_path)
          items << {
            name: item,
            item_path: item_path,
            type: "directory",
            children: build_directory_tree(item_path)
          }
        else
          items << {
            name: item,
            item_path: item_path,
            type: "file"
          }
        end
      end
      items.sort_by { |item| item[:name].downcase }
    end

    @tree = build_directory_tree root_directory_path
    # puts @tree
  end

  def file
    # Function to tell if the file accessed is a binary or a text file
    def text_file?(path, blocksize: 512)
      return false unless File.exist?(path)

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

    @is_text = text_file?(params[:item_path])

    @item_path = params[:item_path]

    if @is_text
      @text = File.read(params[:item_path])
    end

    render partial: "file_grid"
  end

  def folder
    @children = []
    @is_empty = params[:children_name].nil?
    @item_path = params[:item_path]

    unless @is_empty
      params[:children_name].length.times do |i|
        @children << {name: params[:children_name][i], item_path: params[:children_path][i], type: params[:children_type][i]}
      end
    end
    
    render partial: "folder_view"
  end

  def save
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
end

class MainController < ApplicationController
  def index
    root_directory_path = Dir.pwd

    def build_directory_tree(path)
      items = []
      Dir.foreach(path) do |item|
        next if item[0] == '.' && File.directory?(item) # rubocop:disable Style/StringLiterals

        item_path = File.join(path, item)

        #puts path.gsub("/", "_")

        if File.directory?(item_path)
          items << {
            name: item,
            path: path,
            item_path: item_path,
            type: "directory",
            children: build_directory_tree(item_path)
          }
        else
          items << {
            name: item,
            path: path,
            item_path: item_path,
            type: "file"
          }
        end
      end
      items
    end

    @tree = build_directory_tree root_directory_path
  end
end

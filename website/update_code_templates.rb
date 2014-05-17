#!/usr/bin/env ruby

require 'find'
require 'fileutils'

require 'rubygems'
require 'json'

class MyFile

  def template_names
    results = []
    Find.find("../code_templates") do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == ?. and File.basename(path) != '.'
          Find.prune
        else
          results << File.basename(path)
          next
        end
      end
    end
    results.reject{|x| x == "code_templates"}.sort
  end

  def files_and_values_for_template(template_name)
    results = []
    Find.find("../code_templates/#{template_name}") do |path|
      if ! FileTest.directory?(path)
        h = {}
        h[:name] = File.basename(path)
        h[:value] = File.read(path)
        results << h
      end
    end
    results
  end

end

class Application

  def run
    results = {}
    MyFile.new.template_names().each do |template|

      # [tag:fix:gem] these two don't work for some reason... fix soon
      if ["linked_list_in_go", "linked_list_python"].include?(template)
        next
      end
      puts template
      h = {:files => MyFile.new.files_and_values_for_template(template)}
      results[:"#{template}"] = h
    end
    File.open("content/code_templates.js", 'w') { |file| file.write("window.code_templates = " + results.to_json) }
  end

end

app = Application.new()
app.run()
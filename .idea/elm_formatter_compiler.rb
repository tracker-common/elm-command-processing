#!/usr/bin/env ruby

require 'rubygems'
require 'tmpdir'
require 'pathname'
require 'json'
require 'stringio'

# Designed to be used as a Jetbrains IDe
# custom File Watcher (https://www.jetbrains.com/help/ruby/2016.2/file-watchers.html)
# which runs elm-format, elm-make for multiple elm apps, and formats elm-make output
# in a way which allows the File Watcher output filter to correctly highlight elm source
# file clickable links.
#
# USAGE:
#
# PROJECT_ROOT:     root dir of your project, default '..'
# ELM_APPS_TO_MAKE: comma-delimited list of directory names containing an 'elm-stuff' dir to make.
#                   Defaults to all dirs under PROJECT_ROOT containing an 'elm-stuff' dir
# ELM_MAKE_REPORT:  'normal', 'json', or 'custom'.  'normal' and 'json' uses theses as the value
#                   for the standard 'elm-make' '--report=' option.  'custom' will parse the output
#                   of 'elm'
# VERBOSE:          prints out commands lines as they are run
class ElmFormatterCompiler
  attr_reader :project_root, :elm_apps_to_make, :elm_make_report, :exit_status, :last_exit_status, :verbose

  def initialize
    @project_root = File.expand_path(ENV.fetch('PROJECT_ROOT', "#{__FILE__}/../.."))
    raise "PROJECT_ROOT #{project_root} does not exist!" unless File.exist?(project_root)
    @elm_apps_to_make = ENV.fetch('ELM_APPS_TO_MAKE', '').split(',')
    @elm_make_report = ENV.fetch('ELM_MAKE_REPORT', 'custom').to_sym
    @verbose = ENV.fetch('VERBOSE', 'false') == 'true'
    @exit_status = 0
  end

  def run
    # run elm-format from directory containing all elm code
    puts "Running elm-format for #{elm_apps_root_dir}...".black.bold.bg_gray
    elm_format_cmd = "#{elm_format_exec} --yes #{elm_apps_root_dir}"
    process(elm_format_cmd)

    # run elm-make on all elm apps
    elm_app_roots.each do |elm_app_root|
      elm_make(elm_app_root)
    end
  end

  private

  def elm_format_exec
    '/usr/local/bin/elm-format'
  end

  def elm_make_exec
    '/usr/local/bin/elm-make'
  end

  def elm_make_entry_point(elm_app_root)
    Dir.glob("#{elm_app_root}/**/Suite.elm").first
  end

  def elm_apps_root_dir
    "#{project_root}/src/elm"
  end

  def elm_app_roots
    elm_stuff_dirs = Dir.glob("#{elm_apps_root_dir}/**/elm-stuff")
    roots = elm_stuff_dirs.map do |elm_stuff_dir|
      File.expand_path("#{elm_stuff_dir}/..")
    end
    unless elm_apps_to_make.empty?
      roots = roots.reject do |root|
        !elm_apps_to_make.include?(app_name_from_root(root))
      end
    end
    roots
  end

  def app_name_from_root(elm_app_root)
    Pathname.new(elm_app_root).split.last.to_s
  end

  def process(cmd)
    puts cmd if verbose
    output = `#{cmd}`
    @last_exit_status = $?.exitstatus
    @exit_status = last_exit_status unless last_exit_status == 0
    output
  end

  def elm_make(elm_app_root)
    app_name = app_name_from_root(elm_app_root)
    output_file = "/tmp/#{app_name}.html"
    elm_make_report_option = elm_make_report == :custom ? :json : elm_make_report
    elm_make_cmd = "cd #{elm_app_root} && " \
      "#{elm_make_exec} #{elm_make_entry_point(elm_app_root)} " \
      "--report=#{elm_make_report_option} --yes --warn --output #{output_file}"
    puts "Running elm-make for #{app_name}...".black.bold.bg_gray
    elm_make_output = process(elm_make_cmd)
    if elm_make_report == :custom
      puts format_elm_make_output(elm_make_output, elm_app_root)
    else
      puts elm_make_output
    end
  end

  def divider
    "#{('—'*80)}\n".gray
  end

  def format_elm_make_output(elm_make_output, elm_app_root)
    elm_make_result = parse_elm_make_result(elm_make_output)
    if elm_make_result == :success
      return elm_make_output.green
    end

    output = StringIO.new

    if elm_make_result == :error_text
      output.write(elm_make_output.red)
      return output.string
    end

    scrubbed_elm_make_output = elm_make_output.gsub(/^Successful.*$/, '')

    # sometimes there will be two arrays emitted on separate lines (which isn't valid JSON, so process each line and join them)
    errors = []
    scrubbed_elm_make_output.split("\n").each do |line|
      errors += JSON.parse(line)
    end

    formatted_errors = errors.map do |error|
      format_elm_error(error, elm_app_root)
    end
    divided_formatted_errors = formatted_errors.join(divider)
    output.write(divided_formatted_errors)
    output.string
  end

  def parse_elm_make_result(elm_make_output)
    return :error_json if elm_make_output =~ /"tag":"/
    return :error_text unless elm_make_output =~ /^Successful.*$/
    return :success
  end

  def format_elm_error(error, elm_app_root)
    type = error.fetch('type')
    color = type == 'warning' ? :yellow : :red
    tag = error.fetch('tag')
    overview = error.fetch('overview')
    details = error.fetch('details')
    details.gsub!("\n\n", "\n")
    file = error.fetch('file').gsub('./', "#{elm_app_root}/").gsub(project_root, '.')
    region_start = error.fetch('region').fetch('start')
    region_start_line = region_start.fetch('line')
    region_start_col = region_start.fetch('column')
    error_file_location = "#{file}:#{region_start_line}:#{region_start_col}"
    "#{error_file_location}\n".send(color) +
        "#{type.upcase}: #{tag} - #{overview}\n".bold.send(color) +
        "#{details}\n".send(color)
  end
end

# from http://stackoverflow.com/questions/1489183/colorized-ruby-output
class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def black
    colorize(30)
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def brown
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def magenta
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

  def gray
    colorize(37)
  end

  def bg_gray
    colorize(47)
  end

  def bold
    "\e[1m#{self}\e[22m"
  end

  def italic
    "\e[3m#{self}\e[23m"
  end

  def underline
    "\e[4m#{self}\e[24m"
  end

  def no_colors
    self.gsub /\e\[\d+m/, ""
  end
end

efc = ElmFormatterCompiler.new
efc.run
exit efc.exit_status

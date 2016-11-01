#require 'set'
require 'digest'
require 'exifr'

Photos_dir = 'E:/cassiopeia/photos'
Extensions = { photo: %w(jpg jpeg), video: %w(mp4 avi 3gp) }

file_paths = Dir[File.join(Photos_dir, '**', '*')].reject { |path| File.directory? path }

#extensions = Hash.new { |h, k| h[k] = [] }
sizes = Hash.new { |h, k| h[k] = [] }
file_paths.each do |path|
#    extensions[File.extname(path)[1..-1].downcase].push path
    sizes[File.size path].push path
end
#sizes.reject! { |size, paths| paths.length == 1 }

#extensions.each { |extension, paths| puts "#{extension}: #{paths.count}" }
#
#sizes.each do |size, paths|
#    puts "#{size}:"
#    paths.each { |path| puts "  - #{path}" }
#end
#
#diff_names = Hash.new
#sizes.each do |size, paths|
#    current = Set.new
#    paths.each do |path_i|
#        paths.each do |path_j|
#            next if path_i == path_j
#            current << path_i << path_j unless File.basename(path_i) == File.basename(path_j)
#        end
#    end
#    diff_names[size] = current unless current.empty?
#end
#
#diff_names.each do |size, paths|
#    puts "#{size}:"
#    paths.each { |path| puts "  - #{path}" }
#end

unique_files = []
sizes.each do |size, paths_i|
    if paths_i.count == 1
        unique_files << paths_i.first
        next
    end
    checksums = Hash.new { |h, k| h[k] = [] }
    paths_i.each { |path| checksums[Digest::MD5.file(path).hexdigest] << path }
    checksums.each do |checksum, paths_j|
        if paths_j.count == 1
            unique_files << paths_j.first
            next
        end
        unique_files << paths_j.min_by { |path| File.stat(path).mtime }
    end
end

files = Hash.new { |h, k| h[k] = [] }
unique_files.each do |path|
    extension = File.extname(path)[1..-1].downcase
    Extensions.each do |type, extensions|
        if extensions.include? extension
            files[type] << path
            break
        end
    end
end

puts "all file count: #{file_paths.count}", "unique file count: #{unique_files.count}"
files.each { |type, paths| puts "#{type}: #{paths.count}" }


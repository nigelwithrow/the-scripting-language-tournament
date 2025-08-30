require "zlib"
require "rubygems/package"
require "stringio"

module LostInFiles
	include Zlib
	include Gem

	TarReader = Package::TarReader

	def self.scan(file)
		if file.class == String
			gz = GzipReader.open file
		elsif file.class == StringIO
			gz = GzipReader.wrap file
		end
		tar = TarReader.new gz
		tar.each { |entry|
			next if not entry.file?
			# puts entry.full_name
			if entry.full_name[-7, 7] == ".tar.gz"
				scan StringIO.new entry.read
			else
				entry.read.split("\n") { |line|
					puts line if line[0, 8] == "Answer: "
				}
			end
		}
		tar.close
	end
end

# Simple build script
# Deletes the existing gem file (if present)
# Uninstalls the gem
# Builds the gem
# Installs the new gem

# Note : when calling system (or backticks, etc.) th enew process starts at the system default, not the current working directory.
# Therefore we need to use a syntax of : system "cd #{gem_dir} && #{i_cmd}"

# Run from this directory!

gem_dir = Dir.getwd

# Delete existing .gem files in the dir

gemfiles = Dir.entries(gem_dir).collect {|q| q if q =~ /.gem$/}.compact

gemfiles.each do |q| 
	File.delete q
	puts "Deleted #{q}"
end

gemfiles = Dir.entries(gem_dir).collect {|q| q if q =~ /.gem$/}.compact
raise "Gem has not been deleted" unless gemfiles.size == 0

# Uninstall, build, install
gemspecs = Dir.entries(gem_dir).collect {|q| q if q =~ /.gemspec$/}.compact

raise "Did not find a .gemspec in #{gem_dir}" if gemspecs.size < 1
raise "Found more than one .gemspec in #{gem_dir}" if gemspecs.size > 1

gemspec = gemspecs[0]

gemname = File.basename(gemspec, File.extname(gemspec))

u_cmd = "gem uninstall #{gemname}"
system u_cmd

b_cmd = "gem build #{gemspec}"
system "cd #{gem_dir} && #{b_cmd}"

gemfiles = Dir.entries(gem_dir).collect {|q| q if q =~ /.gem$/}.compact
raise "Gem was not built" unless gemfiles.size == 1

gemfile = gemfiles[0]
raise "Gem file is not for the expected gem, expected a #{gemname} gem but found #{gemfile}" unless gemfile =~ /^#{gemname}/

i_cmd = "gem install #{gemfile}"
system "cd #{gem_dir} && #{i_cmd}"

puts "Gem #{gemname} built & installed"
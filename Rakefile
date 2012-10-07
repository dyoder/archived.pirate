
desc "Run all the pirate tests"
task "test" do
  FileList["tests/*.coffee"].exclude("tests/testify.coffee").each do |path|
    sh "coffee #{path}"
  end
end
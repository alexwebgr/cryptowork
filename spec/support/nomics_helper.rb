RSpec.shared_context("nomics_helper") do
  def file_fixture(fixture_name)
    Pathname.new(File.join('spec/fixtures', fixture_name))
  end
end

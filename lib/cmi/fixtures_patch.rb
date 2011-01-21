# Redefines Fixtures.read_csv_fixture_files to be able to insert NULLs.
class Fixtures
  private

  def read_csv_fixture_files
    reader = CSV.parse(erb_render(IO.read(csv_file_path)))
    header = reader.shift
    i = 0
    reader.each do |row|
      data = {}
      row.each_with_index { |cell, j| data[header[j].to_s.strip] = cell.nil? ? nil : cell.to_s.strip }
      self["#{@class_name.to_s.underscore}_#{i+=1}"] = Fixture.new(data, model_class, @connection)
    end
  end
end

# Load data from a file
# @param filename [String] name of the file where to load the data
# @return [Object]
def load_data(filename)
  Marshal.load(File.binread(filename))
end

# Save data to a file
# @param data [Object] data to save to a file
# @param filename [String] name of the file
def save_data(data, filename)
  File.binwrite(filename, Marshal.dump(data))
  return nil
end

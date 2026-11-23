class PageUploader < CarrierWave::Uploader::Base

  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/meta-images/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    "/static/honey-comb-share-default.png"
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # version :jpg do
  #   process convert: :jpg
  #   process resize_to_limit: [600, 777]
  #   process optimize: [{ quality: 70 }] if RUBY_PLATFORM =~ /x86_64-linux/
  #   def full_filename (for_file = model.source.file)
  #     "#{model.slug}.jpg"
  #   end
  # end

  # version :webp, from_version: :jpg do
  #   process convert_to_webp: [{ quality: 80, method: 6 }] if RUBY_PLATFORM =~ /x86_64-linux/
  #   def full_filename (for_file = model.source.file)
  #     "#{model.slug}.webp"
  #   end
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
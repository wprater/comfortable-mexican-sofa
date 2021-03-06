require File.expand_path('../../test_helper', File.dirname(__FILE__))

class CmsFileTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Cms::File.all.each do |file|
      assert file.valid?, file.errors.full_messages.to_s
    end
  end
  
  def test_validations
    assert_no_difference 'Cms::File.count' do
      file = Cms::File.create
      assert file.errors.present?
      assert_has_errors_on file, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'Cms::File.count' do
      file = cms_sites(:default).files.create(
        :file => fixture_file_upload('files/image.jpg', 'image/jpeg')
      )
      assert_equal 'Image', file.label
      assert_equal 'image.jpg', file.file_file_name
      assert_equal 'image/jpeg', file.file_content_type
      assert file.file_file_size > 6000
      assert_equal 1, file.position
    end
  end
  
  def test_create_with_dimensions
    assert_difference 'Cms::File.count' do
      file = cms_sites(:default).files.create!(
        :dimensions => '10x10#',
        :file       => fixture_file_upload('files/image.jpg', 'image/jpeg')
      )
      assert_equal 'Image', file.label
      assert_equal 'image.jpg', file.file_file_name
      assert_equal 'image/jpeg', file.file_content_type
      assert file.file_file_size < 6000
      assert_equal 1, file.position
    end
  end
  
  def test_create_failure
    assert_no_difference 'Cms::File.count' do
      cms_sites(:default).files.create(:file => '')
    end
  end
  
  def test_image_mimetypes
    assert_equal %w(image/gif image/jpeg image/pjpeg image/png image/svg+xml image/tiff),
      Cms::File::IMAGE_MIMETYPES
  end
  
  def test_images_scope
    file = cms_files(:default)
    assert_equal 'image/jpeg', file.file_content_type
    assert_equal 1, Cms::File.images.count
    assert_equal 0, Cms::File.not_images.count
    
    file.update_attribute(:file_content_type, 'application/pdf')
    assert_equal 0, Cms::File.images.count
    assert_equal 1, Cms::File.not_images.count
  end
end

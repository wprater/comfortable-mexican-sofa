class Cms::Block
  include Mongoid::Document
  include Mongoid::Timestamps

  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_blocks

  field :label,    type: String
  field :content,  type: String
  
  # -- Relationships --------------------------------------------------------
  belongs_to :page, class_name: 'Cms::Page'
  has_many :files,
    :class_name => 'Cms::File',
    :autosave   => true,
    :dependent  => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_save :prepare_files
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :page_id }
    
  # -- Instance Methods -----------------------------------------------------
  # Tag object that is using this block
  def tag
    @tag ||= page.tags(true).detect{|t| t.is_cms_block? && t.label == label}
  end
    
protected
  
  def prepare_files
    temp_files = [self.content].flatten.select do |f|
      %w(ActionDispatch::Http::UploadedFile Rack::Test::UploadedFile).member?(f.class.name)
    end
    
    # only accepting one file if it's PageFile. PageFiles will take all
    single_file = self.tag.is_a?(ComfortableMexicanSofa::Tag::PageFile)
    temp_files = [temp_files.first].compact if single_file
    
    temp_files.each do |file|
      self.files.collect{|f| f.mark_for_destruction } if single_file
      self.files.build(:site => self.page.site, :dimensions => self.tag.try(:dimensions), :file => file)
    end
    
    self.content = nil unless self.content.is_a?(String)
  end
end

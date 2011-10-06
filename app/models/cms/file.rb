class Cms::File
  IMAGE_MIMETYPES = %w(gif jpeg pjpeg png svg+xml tiff).collect{|subtype| "image/#{subtype}"}

  include Mongoid::Document
  include Mongoid::Timestamps
  include ComfortableMexicanSofa::IsCategorized
  include Mongoid::Paperclip

  ComfortableMexicanSofa.establish_connection(self)
    
  store_in :cms_files
  
  field :label,           type: String
  field :file_file_name,  type: String
  field :file_content_type, type: String
  field :file_file_size,  type: Integer
  field :description,     type: String
  field :position,        type: Integer,  :default => 0, :null => false
  
  cms_is_categorized
  
  attr_accessor :dimensions
  
  # -- AR Extensions --------------------------------------------------------
  has_mongoid_attached_file :file, ComfortableMexicanSofa.config.upload_file_options.merge(
    # dimensions accessor needs to be set before file assignment for this to work
    :styles => lambda { |f|
      f.instance.dimensions.blank?? { } : { :original => f.instance.dimensions }
    }
  )
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site,   class_name: 'Cms::Site'
  belongs_to :block,  class_name: 'Cms::Block'
  
  # -- Validations ----------------------------------------------------------
  validates :site_id, :presence => true
  validates_attachment_presence :file
  
  # -- Callbacks ------------------------------------------------------------
  before_save   :assign_label
  before_create :assign_position
  after_save    :reload_page_cache
  after_destroy :reload_page_cache
  
  # -- Scopes ---------------------------------------------------------------
  scope :images,      any_in(file_content_type: IMAGE_MIMETYPES)
  scope :not_images,  not_in(file_content_type: IMAGE_MIMETYPES)
  default_scope order_by(:position)
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.file_file_name.gsub(/\.[^\.]*?$/, '').titleize : self.label
  end
  
  def assign_position
    max = Cms::File.max(:position)
    self.position = max ? max + 1 : 0
  end
  
  # FIX: Terrible, but no way of creating cached page content overwise
  def reload_page_cache
    return unless self.block
    self.block.page.save!
  end
  
end

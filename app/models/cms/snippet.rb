class Cms::Snippet
  include Mongoid::Document
  include Mongoid::Timestamps
  include ComfortableMexicanSofa::IsCategorized
  include ComfortableMexicanSofa::IsMirrored
  include ComfortableMexicanSofa::HasRevisions

  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_snippets

  field :label,     type: String
  field :slug,      type: String
  field :content,   type: String
  field :position,  type: Integer,  :default => 0,     :null => false
  field :is_shared, type: Boolean,  :default => false, :null => false
  
  cms_is_categorized
  cms_is_mirrored
  cms_has_revisions_for :content
  
  # -- Relationships --------------------------------------------------------
  belongs_to :site, class_name: 'Cms::Site'
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  before_create :assign_position
  after_save    :clear_cached_page_content
  after_destroy :clear_cached_page_content
  
  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :presence   => true,
    :uniqueness => { :scope => :site_id },
    :format     => { :with => /^\w[a-z0-9_-]*$/i }
    
  # -- Scopes ---------------------------------------------------------------
  default_scope order_by(:position)
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
  end
  
  # Note: This might be slow. We have no idea where the snippet is used, so
  # gotta reload every single page. Kinda sucks, but might be ok unless there
  # are hundreds of pages.
  def clear_cached_page_content
    site.pages.all.each{ |page| page.save }
  end
  
  def assign_position
    max = self.site.snippets.maximum(:position)
    self.position = max ? max + 1 : 0
  end
  
end

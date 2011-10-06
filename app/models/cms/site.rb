class Cms::Site
  include Mongoid::Document
  
  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_sites
  
  # -- Relationships --------------------------------------------------------
  has_many :layouts,  :dependent => :destroy
  has_many :pages,    :dependent => :destroy
  has_many :snippets, :dependent => :destroy
  has_many :files,    :dependent => :destroy
  
  # -- Callbacks ------------------------------------------------------------
  before_validation :assign_label
  before_save :clean_path
  
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true
  validates :hostname,
    :presence   => true,
    :uniqueness => { :scope => :path },
    :format     => { :with => /^[\w\.\-]+$/ }
    
  # -- Scopes ---------------------------------------------------------------
  scope :mirrored, where(:is_mirrored => true)
  
  # -- Class Methods --------------------------------------------------------
  # returning the Cms::Site instance based on host and path
  def self.find_site(host, path = nil)
    return Cms::Site.first if Cms::Site.count == 1
    cms_site = nil
    Cms::Site.find_all_by_hostname(host).each do |site|
      if site.path.blank?
        cms_site = site
      elsif "#{path}/".match /^\/#{Regexp.escape(site.path.to_s)}\//
        cms_site = site
        break
      end
    end
    return cms_site
  end
  
protected
  
  def assign_label
    self.label = self.label.blank?? self.hostname : self.label
  end
  
  def clean_path
    self.path ||= ''
    self.path.squeeze!('/')
    self.path.gsub!(/\/$/, '')
  end
  
end
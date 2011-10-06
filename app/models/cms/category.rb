class Cms::Category
  include Mongoid::Document
  
  ComfortableMexicanSofa.establish_connection(self)
  
  store_in :cms_categories

  field :label,             type: String
  field :categorized_type,  type: String
  
  # -- Relationships --------------------------------------------------------
  # has_many :categorizations,
  #   :class_name => 'Cms::Categorization',
  #   :dependent => :destroy
    
  # -- Validations ----------------------------------------------------------
  validates :label,
    :presence   => true,
    :uniqueness => { :scope => :categorized_type }
  validates :categorized_type,
    :presence   => true
    
  # -- Scopes ---------------------------------------------------------------
  default_scope order_by(:label)
  scope :of_type, lambda { |type|
    where(:categorized_type => type)
  }
  
end
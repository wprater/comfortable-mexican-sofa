module ComfortableMexicanSofa::IsMirrored
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def cms_is_mirrored
      include ComfortableMexicanSofa::IsMirrored::InstanceMethods
      
      attr_accessor :is_mirrored
      
      after_save    :sync_mirror
      after_destroy :destroy_mirror
    end
  end
  
  module InstanceMethods
    
    # Mirrors of the object found on other sites
    def mirrors
      return [] unless self.site.is_mirrored?
      (Cms::Site.mirrored - [self.site]).collect do |site|
        case self
          when Cms::Layout  then site.layouts.find_by_slug(self.slug)
          when Cms::Page    then site.pages.find_by_full_path(self.full_path)
          when Cms::Snippet then site.snippets.find_by_slug(self.slug)
        end
      end.compact
    end
    
    # Creating or updating a mirror object. Relationships are mirrored
    # but content is unique. When updating need to grab mirrors based on
    # self.slug_was, new objects will use self.slug.
    def sync_mirror
      return if self.is_mirrored
      
      (Cms::Site.mirrored - [self.site]).each do |site|
        mirror = case self
        when Cms::Layout
          m = site.layouts.find_by_slug(self.slug_was || self.slug) || site.layouts.new
          m.attributes = {
            :slug       => self.slug,
            :parent_id  => site.layouts.find_by_slug(self.parent.try(:slug)).try(:id)
          }
          m
        when Cms::Page
          m = site.pages.find_by_full_path(self.full_path_was || self.full_path) || site.pages.new
          m.attributes = {
            :slug       => self.slug,
            :label      => self.slug.blank?? self.label : m.label,
            :parent_id  => site.pages.find_by_full_path(self.parent.try(:full_path)).try(:id),
            :layout     => site.layouts.find_by_slug(self.layout.slug)
          }
          m
        when Cms::Snippet
          m = site.snippets.find_by_slug(self.slug_was || self.slug) || site.snippets.new
          m.attributes = {
            :slug => self.slug
          }
          m
        end
        
        mirror.is_mirrored = true
        mirror.save!
      end
    end
    
    # Mirrors should be destroyed
    def destroy_mirror
      return if self.is_mirrored
      mirrors.each do |mirror|
        mirror.is_mirrored = true
        mirror.destroy
      end
    end
  end
  
end

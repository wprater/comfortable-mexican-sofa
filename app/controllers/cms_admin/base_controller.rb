class CmsAdmin::BaseController < ApplicationController

  protect_from_forgery

  # Authentication module must have #authenticate method
  include ComfortableMexicanSofa.config.admin_auth.to_s.constantize

  before_filter :authenticate,
                :load_admin_site,
                :load_fixtures,
                :except => :jump
  
  layout 'cms_admin'
  
  def jump
    path = ComfortableMexicanSofa.config.admin_route_redirect
    return redirect_to(path) unless path.blank?
    load_admin_site
    redirect_to cms_admin_site_pages_path(@site) if @site
  end
  
protected
  
  def load_admin_site
    unless (@site = Cms::Site.find(params[:site_id]) rescue Cms::Site.first)
      I18n.locale = ComfortableMexicanSofa.config.admin_locale || I18n.default_locale
      flash[:error] = I18n.t('cms.base.site_not_found')
      return redirect_to(new_cms_admin_site_path)
    end
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || @site.locale
  end

  def load_fixtures
    return unless ComfortableMexicanSofa.config.enable_fixtures
    ComfortableMexicanSofa::Fixtures.import_all(@site.hostname)
    if %w(cms_admin/layouts cms_admin/pages cms_admin/snippets).member?(params[:controller])
      flash.now[:error] = I18n.t('cms.base.fixtures_enabled')
    end
  end
end

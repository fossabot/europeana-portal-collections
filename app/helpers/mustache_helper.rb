module MustacheHelper
  def head_meta
    [
      #{'name':'X-UA-Compatible',    content: 'IE=edge' },
      #{'name':'viewport',           content: 'width=device-width,initial-scale=1.0' },
      { meta_name: 'HandheldFriendly',   content: 'True' },
      { httpequiv: 'Content-Type',       content: 'text/html; charset=utf-8' },
      { meta_name: 'csrf-param',         content: 'authenticity_token' },
      { meta_name: 'csrf-token',         content: form_authenticity_token }
    ]
  end

  def form_search
    {
      action: search_action_path(only_path: true)
    }
  end

  def head_links
    [
      # { rel: 'shortcut icon', type: 'image/x-icon', href: asset_path('favicon.ico') },
      { rel: 'stylesheet', href: styleguide_path('/css/search/screen.css'), media: 'all' }
    ]
  end

  # model for the search form
  def input_search
    {
      title: t('global.search-area.search-button-image-alt'),
      input_name: params[:q].blank? ? 'q' : 'qf[]',
      has_original: !params[:q].blank?,
      input_original: {
        value:  params[:q].blank? ? nil : params[:q],
        remove: search_action_url(remove_q_param(params))
      },
      input_values: input_search_values(*search_param_keys),
      placeholder: t('site.search.placeholder.text')
    }
  end

  def image_root
    styleguide_path('/images/')
  end

  def version
    { is_alpha: true }
  end

  def js_variables
    "var js_path='" + styleguide_path('/js/dist/') + "';"
  end

  def js_files
    js_entry_point = Rails.application.config.x.js_entrypoint || '/js/dist/'
    js_entry_point = js_entry_point.dup << '/' unless js_entry_point.end_with?('/')
    [{ path: styleguide_path(js_entry_point + 'require.js'),
       data_main: styleguide_path(js_entry_point + 'main/main') }]
  end

  def menus
    {
      actions: {
        button_title: 'Actions',
        menu_id: 'dropdown-result-actions',
        menu_title: 'Save to:',
        items: [
          {
            url: 'http://europeana.eu',
            text: 'First Item'
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label'
          },
          {
            url: 'http://europeana.eu',
            text: 'Label here'
          },
          {
            url: 'http://europeana.eu',
            text: 'Fourth Item'
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          }
        ]
      },
      sort: {
        button_title: 'Relevance',
        menu_id: 'dropdown-result-sort',
        menu_title: 'Sort by:',
        items: [
          {
            text: 'Date',
            url: 'http://europeana.eu'
          },
          {
            text: 'Alphabetical',
            url: 'http://europeana.eu'
          },
          {
            text: 'Relevance',
            url: 'http://europeana.eu'
          },
          {
            divider: true
          },
          {
            url: 'http://europeana.eu',
            text: 'Another Label',
            calltoaction: true
          },
          {
            divider: true
          },
          {
            text: 'Advanced Search',
            url: 'http://europeana.eu',
            calltoaction: true
          }
        ]
      }
    }
  end

  def total_item_count
    @europeana_item_count ? number_with_delimiter(@europeana_item_count) : nil
  end

  def channels_nav_links
    available_channels.collect do |c|
      {
        url: channel_path(c),
        text: c
      }
    end
  end

  def page_config
    {
      newsletter: false
    }
  end

  def navigation
    {
      global: {
        options: {
          search_active: false,
          settings_active: false
        },
        logo: {
          url: root_url,
          text: 'Europeana Search'
        },
        primary_nav: {
          items: [
            {
              url: root_url,
              text: 'Home',
              is_current: controller.controller_name != 'channels'
            },
            # {
            #   url: channel_url('music'),
            #   text: 'Channels',
            #   is_current: controller.controller_name == 'channels',
            #   submenu: {
            #     items: [
            #       {
            #         url: channel_url('art'),
            #         text: 'Art History'
            #       },
            #       {
            #         url: channel_url('music'),
            #         text: 'Music'
            #       }
            #     ]
            #   }
            # },
            # {
            #   url: 'http://exhibitions.europeana.eu/',
            #   text: 'Exhibitions'
            # },
            # {
            #   url: 'http://blog.europeana.eu/',
            #   text: 'Blog'
            # },
            # {
            #   url: 'http://www.europeana.eu/portal/myeuropeana#login',
            #   text: 'My Europeana'
            # }
          ]
        }  # end prim nav
      },
      footer: {
        linklist1: {
          title: t('global.more-info'),
          items: [
            {
              text: t('site.footer.menu.about'),
              url: root_url + '/about.html'
            }
            # {
            #   text: t('site.footer.menu.new-collections'),
            #   url: '#'
            # },
            # {
            #   text: t('site.footer.menu.data-providers'),
            #   url: '#'
            # },
            # {
            #   text: t('site.footer.menu.become-a-provider'),
            #   url: '#'
            # }
          ]
        },
        xxx_linklist2: {
          title: t('global.help'),
          items: [
            {
              text: t('site.footer.menu.search-tips'),
              url: '#'
            },
            {
              text: t('site.footer.menu.using-myeuropeana'),
              url: '#'
            },
            {
              text: t('site.footer.menu.copyright'),
              url: '#'
            }
          ]
        },
        social: {
          facebook: true,
          pinterest: true,
          twitter: true,
          googleplus: true
        }
      }
    }
  end

  def content
    banner = Banner.find_or_initialize_by(key: 'phase-feedback')
    {
      phase_feedback: {
        title: banner.title,
        text: banner.body,
        cta_url: banner.link.url,
        cta_text: banner.link.text
      }
    }
  end

  def styleguide_path(asset = nil)
    Rails.application.config.x.europeana_styleguide_cdn + (asset.present? ? asset : '')
  end

  private

  # @param keys [Symbol] keys of params to gather template input field data for
  # @return [Array<Hash>]
  def input_search_values(*keys)
    return [] if keys.blank?
    keys.map do |k|
      [params[k]].flatten.compact.map do |v|
        {
          name: params[k].is_a?(Array) ? "#{k}[]" : k.to_s,
          value: input_search_param_value(k, v),
          remove: search_action_url(remove_search_param(k, v, params))
        }
      end
    end.flatten.compact
  end

  ##
  # Returns text to display on-screen for an active search param
  #
  # @param key [Symbol] parameter key
  # @param value value of the parameter
  # @return [String] text to display
  def input_search_param_value(key, value)
    case key
    when :mlt
      response, doc = controller.fetch(value)
      item = render_index_field_value(doc, ['dcTitleLangAware', 'title'])
      t('site.search.similar.prefix', mlt_item: item)
    else
      value.to_s
    end
  end

  ##
  # Keys of parameters to preserve across searches as hidden input fields
  #
  # @return [Array<Symbol>]
  def search_param_keys
    [:qf, :mlt]
  end

  def news_items(items)
    items[0..2].map do |item|
      {
        image_root: nil,
        headline: {
          medium: CGI.unescapeHTML(item.title)
        },
        url: CGI.unescapeHTML(item.url),
        img: {
          rectangle: {
            src: news_item_img_src(item),
            alt: nil
          }
        },
        excerpt: {
          short: CGI.unescapeHTML(item.summary)
        }
      }
    end
  end

  def news_item_img_src(item)
    return nil unless item.content.present?
    img_tag = item.content.match(/<img [^>]*>/i)[0]
    return nil unless img_tag.present?
    url = img_tag.match(/src="(https?:\/\/[^"]*)"/i)[1]
    mo = MediaObject.find_by_source_url_hash(MediaObject.hash_source_url(url))
    mo.nil? ? nil : mo.file.url(:medium)
  end

  def hero_config(hero_image)
    hero_license = hero_image.license.blank? ? {} : { license_template_var_name(hero_image.license) => true }
    {
      hero_image: hero_image.file.url,
      attribution_title: hero_image.settings_attribution_title,
      attribution_creator: hero_image.settings_attribution_creator,
      attribution_institution: hero_image.settings_attribution_institution,
      attribution_url: hero_image.settings_attribution_url,
      attribution_text: hero_image.settings_attribution_text,
      brand_opacity: "brand-opacity#{hero_image.settings_brand_opacity}",
      brand_position: "brand-#{hero_image.settings_brand_position}",
      brand_colour: "brand-colour-#{hero_image.settings_brand_colour}"
    }.merge(hero_license)
  end

  def promoted_items(promotions)
    promotions.map do |promo|
      cat_flag = promo.settings_category.blank? ? {} : { :"is_#{promo.settings_category}" => true }
      {
        url: promo.url,
        title: promo.text,
        custom_class: promo.settings_class,
        wide: promo.settings_wide == '1',
        bg_image: promo.file.url
      }.merge(cat_flag)
    end
  end

  ##
  # @param [ActiveRecord::Associations::CollectionProxy<BrowseEntry>
  def channel_entry_items(browse_entries)
    browse_entries.map do |entry|
      cat_flag = entry.settings_category.blank? ? {} : { :"is_#{entry.settings_category}" => true }
      {
        title: entry.title,
        url: channel_path(entry.landing_page.channel.key, q: entry.query),
        image: entry.file.url,
        image_alt: nil
      }.merge(cat_flag)
    end
  end

  def license_template_var_name(license)
    "license_#{license.gsub('-', '_')}"
  end
end

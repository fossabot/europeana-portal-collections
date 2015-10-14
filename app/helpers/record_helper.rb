module RecordHelper
  def more_like_this(similar)
    similar.map do |doc|
      {
        url: document_path(doc, format: 'html'),
        title: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
        img: {
          alt: render_document_show_field_value(doc, ['dcTitleLangAware', 'title']),
          src: render_document_show_field_value(doc, 'edmPreview')
        }
      }
    end
  end

  def paginated_more_like_this(response, similar)
    {
      page: response.current_page,
      per_page: response.limit_value,
      total: response.total_count,
      documents: more_like_this(similar)
    }
  end

  # @todo Refactor for raw API data
  def record_hierarchy(hierarchy)
#    if hierarchy.is_a?(Hash)
#      {
#        parent: hierarchy_node(hierarchy[:parent]),
#        siblings: {
#          items: hierarchy[:preceding_siblings].map { |item| hierarchy_node(item) } +
#            [hierarchy_node(hierarchy[:self])] +
#            hierarchy[:following_siblings].map { |item| hierarchy_node(item) }
#        },
#        children: {
#          items: hierarchy[:children].map { |item| hierarchy_node(item) }
#        }
#      }
#    elsif hierarchy.is_a?(Array)
#      hierarchy.map { |item| hierarchy_node(item) }
#    else
#      hierarchy_node(hierarchy)
#    end
  end

  def hierarchy_node(item)
    return nil unless item.present?
    {
      title: render_document_show_field_value(item, 'title'),
      index: render_document_show_field_value(item, 'index'),
      url: document_path(item, format: 'html'),
      is_current: (item.id == @document.id)
    }
  end

  def record_media_items(record, options = {})
    Document::RecordPresenter.new(record, controller).media_web_resources(options).map do |web_resource|
      Document::WebResourcePresenter.new(web_resource, record, controller).media_item
    end
  end
end

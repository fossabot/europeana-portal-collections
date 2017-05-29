##
# Provides Blacklight search and browse, within a content Collection
class CollectionsController < ApplicationController
  include Europeana::Collections
  include RecordCountsHelper
  include SearchInteractionLogging

  before_action :redirect_to_home, only: :show, if: proc { params[:id] == 'all' }

  def index
    redirect_to_home
  end

  def show
    @collection = find_collection
    @landing_page = find_landing_page
    @collection_stats = collection_stats
    @recent_additions = recent_additions
    @total_item_count = Rails.cache.fetch("record/counts/collections/#{@collection.key}")

    if has_search_parameters?
      (@response, @document_list) = search_results(params)
      log_search_interaction(
        search: params.slice(:q, :f, :mlt, :range).inspect,
        total: @response.total
      )
    end

    respond_to do |format|
      format.html do
        render has_search_parameters? ? { template: '/portal/index' } : { action: 'show' }
      end
      format.rss { render 'catalog/index', layout: false }
      format.atom { render 'catalog/index', layout: false }
      format.json do
        fail ActionController::UnknownFormat unless has_search_parameters?
        render json: {
          search_results: @document_list.map do |doc|
            Document::SearchResultPresenter.new(doc, self, @response).content
          end
        }
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  # The federated action which is used to retrieve federated results via the foederati gem.
  # As federated content is initially only to be present for firstworldwar searches this is implemented here.
  # TODO: this should be extracted to it's own controller so it's available on non-thematic collection searches too.
  def federated
    @collection = find_collection
    provider = params[:provider]
    @query = params[:query]
    if @collection.settings_federated_providers && @collection.settings_federated_providers.detect(provider.to_sym)
      foederati_provider = Foederati::Providers.get(provider.to_sym)
      @federated_results = Foederati.search(provider.to_sym, { query: @query })[provider.to_sym]
      @federated_results.merge!({
        more_results_label: "View more at #{foederati_provider.display_name}",
        more_results_url: format(foederati_provider.urls.site, { query: @query } ),
        tab_subtitle: "#{@federated_results[:total]} Results"
      })

      @federated_results[:search_results] = @federated_results.delete(:results)
      @federated_results[:search_results].each do |result|
        result[:img] = { src: result.delete(:thumbnail) } if result[:thumbnail]
        result[:object_url] = result.delete(:url)
      end
    end
    render json: @federated_results
  end

  def ugc
    # firstworldwar
    @collection = authorize! :show, Collection.find_by_key!('firstworldwar')
  end

  protected

  def _prefixes
    @_prefixes_with_partials ||= super | %w(catalog)
  end

  def start_new_search_session?
    has_search_parameters?
  end

  def find_collection
    Collection.find_by_key!(params[:id]).tap do |collection|
      authorize! :show, collection
    end
  end

  def find_landing_page
    Page::Landing.find_or_initialize_by(slug: "collections/#{@collection.key}").tap do |landing_page|
      authorize! :show, landing_page
    end
  end

  ##
  # Gets from the cache the number of items of each media type within the current collection
  def collection_stats
    collection_stats = EDM::Type.registry.map do |type|
      {
        count: cached_record_count(collection: @collection, type: type),
        text: type.label,
        url: collection_path(q: "TYPE:#{type.id}")
      }
    end
    collection_stats.reject! { |stats| stats[:count] == 0 }
    collection_stats.sort_by { |stats| stats[:count] }.reverse
  end

  def recent_additions
    Rails.cache.fetch("record/counts/collections/#{@collection.key}/recent-additions") || []
  end
end

# frozen_string_literal: true
module Europeana
  ##
  # Methods for working with the Europeana Annotations API
  #
  # TODO: should this be a helper, as it's included by `StoreGalleryAnnotationsJob`?
  module AnnotationsApiConsumer
    extend ActiveSupport::Concern

    def document_annotations(record_id)
      annotations_for_record(record_id).
        map { |annotation| annotation_text_to_display(annotation) }.compact
    rescue Europeana::API::Errors::ServerError, Europeana::API::Errors::ResponseError => error
      # @todo we may not want controller actions to fail if annotations are
      #   unavailable, but we should return something indicating that there
      #   was a failure and perhaps indicate it to the user, e.g. as
      #   "Annotations could not be retrieved".
      logger.error(error.message)
      nil
    end

    def annotations_for_record(record_id, **local_params)
      search_response = annotations_search_for_document(record_id, local_params)
      return [] unless search_response.key?('items')
      annotations_from_search_response(search_response)
    end

    def annotations_search_for_document(record_id, **local_params)
      local_params[:qf] ||= []
      local_params[:qf] += [
        %(generator_name:#{Rails.application.config.x.europeana[:annotations].api_generator_name'] || 'Europeana.eu*'}),
        %(target_uri:"http://data.europeana.eu/item#{record_id}")
      ]
      Europeana::API.annotation.search(annotations_api_search_params(record_id, local_params))
    end

    def annotations_from_search_response(search_response)
      if annotations_search_profile_minimal?(search_response)
        annotations_from_uris(search_response['items'])
      else
        search_response['items']
      end
    end

    def annotations_search_profile_minimal?(search_response)
      search_response['items'].any? { |item| item.is_a?(String) }
    end

    def annotations_from_uris(uris)
      Europeana::API.in_parallel do |queue|
        uris.each do |item|
          provider, id = item.split('/')[-2..-1]
          queue.add(:annotation, :fetch, annotations_api_fetch_params(provider, id))
        end
      end
    end

    def annotation_text_to_display(annotation)
      if annotation['body'].is_a?(String) && annotation['body'] =~ URI.regexp
        annotation['body']
      elsif annotation['body'] && annotation['body']['@graph']
        %w(sameAs isShownAt isShownBy).each do |graph_field|
          return annotation['body']['@graph'][graph_field] if annotation['body']['@graph'][graph_field]
        end
      end
    end

    def annotations_api_search_params(**local_params)
      {
        query: '*:*',
        pageSize: 100
      }.reverse_merge(annotations_api_env_params).merge(local_params)
    end

    def annotation_target_for_record(record_id)
      "http://data.europeana.eu/item#{record_id}"
    end

    def annotations_api_fetch_params(provider, id)
      {
        provider: provider,
        id: id
      }.reverse_merge(annotations_api_env_params)
    end

    def annotations_api_env_params
      {
        wskey: Rails.application.config.x.europeana[:annotations].api_key || Europeana::API.key,
        api_url: Rails.application.config.x.europeana[:annotations].api_url || Europeana::API.url,
      }
    end
  end
end

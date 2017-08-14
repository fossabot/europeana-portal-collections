# frozen_string_literal: true

RSpec.feature 'Page titles' do
  let(:mime_type) { 'application/vnd.api+json' }
  let(:headers_req) { { 'Accept' => mime_type, 'Content-Type' => mime_type } }
  let(:headers_resp) { { 'Accept' => mime_type, 'Content-Type' => mime_type } }

  describe 'home page' do
    it 'has title "Europeana Collections"' do
      visit home_path(:en)
      expect(page).to have_title('Europeana Collections', exact: true)
    end
  end

  describe 'search page' do
    it 'has title "Query - Search Results - Europeana Collections"' do
      query = 'Beethoven'
      visit search_path(:en, q: query)
      expect(page).to have_title("#{query} - Search Results - Europeana Collections", exact: true)
    end

    it 'has title "Search Results - Europeana Collections"' do
      visit search_path(:en, q: '')
      expect(page).to have_title('Search Results - Europeana Collections', exact: true)
    end
  end

  describe 'collections page' do
    it 'has title "Collection name - Europeana Collections"' do
      visit collection_path(:en, 'music')
      expect(page).to have_title('Music - Europeana Collections', exact: true)
    end
  end

  describe 'galleries page' do
    it 'has title "Galleries - Europeana Collections"' do
      visit galleries_path(:en)
      expect(page).to have_title('Galleries - Europeana Collections', exact: true)
    end
    it 'has title "Gallery name - Galleries - Europeana Collections"' do
      visit gallery_path(:en, 'fashion-dresses')
      expect(page).to have_title('Fashion: dresses - Galleries - Europeana Collections', exact: true)
    end
  end

  describe 'explore page' do
    it 'has title "Explore name - Europeana Collections"' do
      visit explore_newcontent_path(:en)
      expect(page).to have_title('What\'s new? - Europeana Collections', exact: true)
      visit explore_people_path(:en)
      expect(page).to have_title('People - Europeana Collections', exact: true)
    end
  end

  describe 'entity page' do
    let(:type) { 'agent' }
    let(:namespace) { 'base' }
    let(:id) { '1234' }
    let(:url) { Europeana::API.url + "/entities/#{type}/#{namespace}/#{id}?wskey=apidemo" }
    it 'has title "Entity Name - Europeana Collections"' do
      stub_request(:get, url).
        to_return(status: 200, body: api_responses(:entities_fetch), headers: { 'Content-Type' => 'application/ld+json' })
      visit entity_path(:en, 'people', id)
      expect(page).to have_title('David Hume - Europeana Collections', exact: true)
    end
  end

  describe 'events page' do
    let(:json_api_url_events) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/events} }
    let(:json_api_url_event) { /\A#{json_api_url_events}\?filter%5Bslug%5D=event-name/ }
    let(:body_event) do
      <<~EOM
        {
          "data": {
            "attributes": {
              "title": "Event name",
              "datepublish": "2017-06-18T11:24:01+00:00",
              "introduction": "",
              "body": ""
            }
          }
        }
      EOM
    end
    let(:body_events) { '' }

    it 'has title "Events - Europeana Collections"' do
      stub_request(:get, json_api_url_events).
        with(headers: headers_req).
        to_return(status: 200, body: body_events, headers: headers_resp)
      visit events_path(:en)
      expect(page).to have_title('Events - Europeana Collections', exact: true)
    end

    it 'has title "Event name - Events - Europeana Collections"' do
      stub_request(:get, json_api_url_event).
        with(headers: headers_req).
        to_return(status: 200, body: body_event, headers: headers_resp)
      visit event_path(:en, 'event-name')
      expect(page).to have_title('Event name - Events - Europeana Collections', exact: true)
    end
  end

  describe 'blog page' do
    let(:json_api_url_blogs) { %r{\A#{Rails.application.config.x.europeana[:pro_url]}/json/blogposts} }
    let(:json_api_url_blog) { /\A#{json_api_url_blogs}\?filter%5Bslug%5D=blog-name/ }
    let(:body_blog) do
      <<~EOM
        {
          "data": {
            "attributes": {
              "title": "Blog name",
              "datepublish": "2017-06-18T11:24:01+00:00",
              "introduction": "",
              "body": ""
            }
          }
        }
      EOM
    end
    let(:body_blogs) { '' }
    it 'has title "Blog - Europeana Collections"' do
      stub_request(:get, json_api_url_blogs).
        with(headers: headers_req).
        to_return(status: 200, body: body_blogs, headers: headers_resp)
      visit blog_posts_path(:en)
      expect(page).to have_title('Blog - Europeana Collections', exact: true)
    end

    it 'has title "Blog name - Blog - Europeana Collections"' do
      stub_request(:get, json_api_url_blog).
        with(headers: headers_req).
        to_return(status: 200, body: body_blog, headers: headers_resp)
      visit blog_post_path(:en, 'blog-name')
      expect(page).to have_title('Blog name - Blog - Europeana Collections', exact: true)
    end
  end

  describe 'static page' do
    it 'has title "Page name - Europeana Collections"' do
      name = 'about'
      visit static_page_path(:en, name)
      expect(page).to have_selector('title', visible: false, text: /\A#{name}[^-]+\- Europeana Collections/i)
    end
  end
end

shared_examples 'a facet presenter' do
  describe '#display' do
    subject { presenter.display }

    it { is_expected.to be_a(Hash) }

    it 'should include a translated title' do
      I18n.backend.store_translations(:en, global: { facet: { header: { field_name.downcase => 'field title' } } })
      expect(subject[:title]).to eq('field title')
    end

    context 'when facet is single-select' do
      let(:field_options) { super().merge(single: true) }

      it 'should include select_one: true' do
        expect(subject[:select_one]).to be(true)
      end
    end

    context 'when facet is not single-select' do
      it 'should include select_one: nil' do
        expect(subject[:select_one]).to be_nil
      end
    end
  end

  describe '#facet_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.facet_item(item) }

    it 'should include a formatted number of results' do
      expect(subject[:num_results]).to eq('1,000')
    end

    context 'when item is not in request params' do
      it 'should include URL to add facet' do
        expect(subject[:url]).to match(facet.name)
      end

      it 'should indicate facet not checked' do
        expect(subject[:is_checked]).to be(false)
      end
    end

    context 'when item is in request params' do
      let(:params) { { f: { facet.name => [item.value] } } }

      it 'should include URL to remove facet' do
        expect(subject[:url]).not_to match(facet.name)
      end

      it 'should indicate facet checked' do
        expect(subject[:is_checked]).to be(true)
      end
    end
  end

  describe '#filter_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.filter_item(item) }
    let(:params) { { f: { facet.name => [item.value] } } }

    it 'should include a translated facet title' do
      I18n.backend.store_translations(:en, global: { facet: { header: { field_name.downcase => 'field title' } } })
      expect(subject[:filter]).to eq('field title')
    end

    it 'should include a translated, capitalized item label' do
      I18n.backend.store_translations(:en, global: { facet: { field_name.downcase => { item1: 'item label' } } })
      expect(subject[:value]).to eq('Item Label')
    end

    it 'should include URL to remove facet' do
      expect(subject[:remove]).not_to match(facet.name)
    end

    it 'should include facet URL param name' do
      expect(subject[:name]).to eq("f[#{facet.name}][]")
    end
  end
end

shared_examples 'a field-showing/hiding presenter' do
  describe '#display' do
    subject { presenter.display(options) }
    let(:options) { { count: 4 } }
    let(:items) { facet_items(6) }

    context 'when options[:count] is 4 and facet has 6 items' do
      context 'with no facet items in request params' do
        it 'should have 4 unhidden items' do
          expect(subject[:items].length).to eq(4)
        end

        it 'should have 2 hidden items' do
          expect(subject[:extra_items][:items].length).to eq(2)
        end
      end

      context 'with 5 facet items in request params' do
        let(:params) { { f: { facet.name => items[0..4].map(&:value) } } }

        it 'should have 5 unhidden items' do
          expect(subject[:items].length).to eq(5)
        end

        it 'should have 1 hidden item' do
          expect(subject[:extra_items][:items].length).to eq(1)
        end
      end
    end
  end
end

shared_examples 'a text-labelled facet item presenter' do
  describe '#facet_item' do
    let(:item) { facet_items(10).first }
    subject { presenter.facet_item(item) }

    it 'should include a translated, capitalized label' do
      I18n.backend.store_translations(:en, global: { facet: { field_name.downcase => { item1: 'item label' } } })
      expect(subject[:text]).to eq('Item Label')
    end
  end
end

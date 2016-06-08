module EDM
  class Type < Base
    def label
      key = i18n.present? ? i18n : id.to_s.downcase
      I18n.t(key, scope: 'site.collections.data-types')
    end
  end
end

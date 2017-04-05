# frozen_string_literal: true

module BlogPosts
  class Show < ApplicationView
    def blog_title
      body_cached? ? title_from_cached_body : presenter.title
    end
    alias_method :page_content_heading, :blog_title

    def head_meta
      mustache[:head_meta] ||= begin
        image = presenter.image(:url)
        image = image[:src] unless image.nil?
        description = truncate(strip_tags(CGI.unescapeHTML(presenter.body)), length: 200)
        
        head_meta = [
          { meta_name: 'description', content: description },
          { meta_property: 'og:description', content: description },
          { meta_property: 'og:image', content: image },
          { meta_property: 'og:title', content: blog_title },
          { meta_property: 'og:sitename', content: blog_title },
          { meta_name: 'twitter:card', content: 'summary' },
          { meta_name: 'twitter:site', content: '@EuropeanaEU' }
        ]
        head_meta + super
      end
    end

    def content
      mustache[:content] ||= begin
        {
          body: presenter.body,
          has_authors: @blog_post.has_authors?,
          authors: presenter.authors,
          has_tags: @blog_post.has_taxonomy?(:tags),
          tags: presenter.tags,
          label: presenter.label,
          date: presenter.date,
          introduction: presenter.introduction,
          blog_image: presenter.image(:url),
          read_time: presenter.read_time,
          social: blog_social
        }
      end
    end

    def blog_social
      {
        url: request.original_url,
        facebook: {
          text: 'Facebook'
        },
        twitter: {
          text: 'Twitter'
        },
        pinterest: {
          text: 'Pinterest'
        },
        googleplus: {
          text: 'Google Plus'
        }
      }
    end

    def navigation
      mustache[:navigation] ||= begin
        {
          back_url: blog_posts_path,
          back_label: t('site.blogs.list.page-title')
        }.reverse_merge(super)
      end
    end

    protected

    def presenter
      @presenter ||= ProResourcePresenter.new(self, @blog_post)
    end
  end
end

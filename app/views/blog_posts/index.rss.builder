# frozen_string_literal: true

# @todo only insert "views/" into our cache keys when it's needed, i.e. in the context of Mustache view classes
#cache(cache_key(@body_cache_key).sub(%r{\Aviews\/}, ''), skip_digest: true) do
  xml.instruct!
  xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
    xml.channel do
      xml.title("Europeana - #{t('global.blogs')}")
      #xml.description(t('site.blogs.description'))
      xml.link(blog_posts_url)
      xml.language(locale.to_s)
      xml.lastBuildDate(Date.parse(@blog_posts.first.datepublish).rfc2822)
      xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: blog_posts_url(format: 'rss'))

      @blog_posts.each do |blog_post|
        xml.item do
          xml.title(blog_post.title)
          xml.link(blog_post_url(blog_post.slug))
          xml.description(blog_post.introduction)
          blog_post.taxonomy[:tags].each do |tag|
            xml.category(tag[1])
          end
          if thumb = blog_post.image
            xml.enclosure(url: blog_post.image[:url], length: 0, type: 'image/*')
          end
          xml.guid(blog_post_url(blog_post.slug))
          xml.pubDate(Date.parse(blog_post.datepublish).rfc2822)
        end
      end
    end
  end
#end

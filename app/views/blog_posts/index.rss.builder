# frozen_string_literal: true
xml.instruct!
xml.rss(version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom') do
  xml.channel do
    xml.title('Europeana - Blogs')
    xml.description(t('site.blogs.description'))
    xml.link(blog_posts_url)
    xml.language(locale.to_s)
    xml.lastBuildDate(Date.parse(@blog_posts.first.datepublish).rfc2822)
    xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: blog_posts_url(format: 'rss'))

    @blog_posts.each do |blog_post|
      presenter = ProResourcePresenter.new(self, blog_post)
      xml.item do
        xml.title(blog_post.title)
        xml.link(blog_post_url(blog_post.slug))
        xml.description(presenter.body)
        blog_post.taxonomy[:tags].each do |tag|
          xml.category(tag[1])
        end
        if (thumb = blog_post.image) && !blog_post.image.blank?
          xml.enclosure(url: thumb[:url], length: 0, type: 'image/*')
        end
        xml.guid(blog_post_url(blog_post.slug))
        xml.pubDate(Date.parse(blog_post.datepublish).rfc2822)
      end
    end
  end
end

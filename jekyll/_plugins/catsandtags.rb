# Source: http://realjenius.com/2012/12/01/jekyll-category-tag-paging-feeds/
#
module Jekyll
  class CatsAndTags < Generator
    def generate(site)
      site.categories.each do |category|
        build_subpages(site, "category", category)
      end
      site.tags.each do |tag|
        build_subpages(site, "tag", tag)
      end
    end

    def build_subpages(site, type, posts)
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }
      paginate(site, type, posts)
    end

    def paginate(site, type, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts[1], site.config['paginate'].to_i)
      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts[1], pages)
        path = "/#{type}/#{posts[0]}"
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPage.new(site, site.source, path, type, posts[0])
        newpage.pager = pager
        site.pages << newpage
      end
    end

  end

  class GroupSubPage < Page
    def initialize(site, base, dir, type, val)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "blog.html")
      self.data["format"]    = 'blog-index'
      self.data["grouptype"] = type
      self.data["group"]     = val
    end
  end

end

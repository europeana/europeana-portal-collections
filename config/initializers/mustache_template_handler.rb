# Courtesy of http://runnable.com/Una_jPWMKe5YAAAl/how-to-render-templates-with-mustache-for-ruby-on-rails

# Tell Rails how to render mustache templates
module MustacheTemplateHandler
  def self.call(template)
    #assigns contains all the instance_variables defined on the controller's view method
    "Mustache.render(#{template.source.inspect}, assigns).html_safe"
  end
end

# Register a mustache handler in the Rails template engine
ActionView::Template.register_template_handler(:mustache, MustacheTemplateHandler)

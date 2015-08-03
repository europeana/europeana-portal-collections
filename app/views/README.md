# app/views

The app/views directory in this project contains both view templates and view
classes for the presentation logic needed to supply data to
[Mustache templates](https://github.com/mustache/mustache).

These view classes should subclass the `ApplicationView` class, itself a
subclass of `Stache::Mustache::View`. For further information, see the
[Stache gem documentation](https://github.com/agoragames/stache).

Most templates for the application will come from the
[europeana-styleguide gem](https://github.com/europeana/europeana-styleguide-ruby).

Individual templates present in the app/views directory of 
europeana-styleguide can be overriden for this application by creating
a template of the same file name beneath this directory.

## File naming

To remain consistent with Rails conventions, it is recommended to follow its
naming convention for templates, and then render within them the required
styleguide page template.

## Example

**/app/views/portal/index.rb**
```ruby
module Portal
  class Index < ApplicationView
    def page_title
      'Europeana Portal'
    end
  end
end
```

**/app/views/portal/index.html.mustache**
```mustache
{{>atoms/meta/_head}}
{{>templates/Search/Search-results-list}}
{{>atoms/meta/_foot}}
```

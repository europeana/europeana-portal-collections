# app/views

The app/views directory in this project does *not* contain view templates, but
instead contains view classes for the presentation logic needed to supply data
to Mustache templates.

These view classes should subclass the `ApplicationView` class, itself a
subclass of `Stache::Mustache::View`.

For detailed information, see the
[Stache gem documentation](https://github.com/agoragames/stache).

The Mustache *templates* are stored in the app/ui-components directory.

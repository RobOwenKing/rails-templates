# Rails Templates

Quickly generate a Rails 7 app with a selection of useful gems pre-installed.

Based on templates from coding bootcamp [Le Wagon](https://www.lewagon.com). For more on Rails templates, see [here](http://guides.rubyonrails.org/rails_application_templates.html).

## Minimal

Get a minimal rails app ready to be deployed on Heroku with Bootstrap, Simple form and debugging gems.

```bash
rails new \
  -d postgresql \
  -j webpack \
  -m https://raw.githubusercontent.com/RobOwenKing/rails-templates/main/minimal.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

## Devise

Same as minimal **plus** a Devise install with a generated `User` model.

```bash
rails new \
  -d postgresql \
  -j webpack \
  -m https://raw.githubusercontent.com/RobOwenKing/rails-templates/main/devise.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

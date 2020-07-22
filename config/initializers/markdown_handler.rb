require 'action_view/template/handlers/markdown'

ActionView::Template.register_template_handler(:md, ActionView::Template::Handlers::Markdown.new)

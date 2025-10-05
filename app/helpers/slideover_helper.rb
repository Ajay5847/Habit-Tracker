module SlideoverHelper
  def slideover_content(title:, footer: nil, &block)
    render partial: "shared/slideover", locals: { title: title, footer: footer }, &block
  end
end

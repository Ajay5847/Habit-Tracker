module SlideoverHelper
  def slideover_content(title, tabs = [], headericon = "file-text", &)
    content_for :slideover_content do
      restrict_rendering_format(:html) do
        render("shared/slideover_content", title:, tabs:, headericon:, &)
      end
    end
  end

  def close_slideover
    content_for :slideover_content do
      render("shared/slideover_content")
    end
  end

private

  def restrict_rendering_format(format)
    old_formats = formats
    self.formats = [ format ]
    yield
  ensure
    self.formats = old_formats
  end
end

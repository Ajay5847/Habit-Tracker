module ModalHelper
  def modal_content(title, tabs = [], headericon = "file-text", &)
    content_for :modal_content do
      restrict_rendering_format(:html) do
        render("shared/modal_content", title:, tabs:, headericon:, &)
      end
    end
  end

  def clode_modal
    content_for :modal_content do
      render("shared/modal_content")
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

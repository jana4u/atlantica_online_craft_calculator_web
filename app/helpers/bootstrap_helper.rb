module BootstrapHelper
  def navbar_link_to(name = nil, options = nil, html_options = nil, &block)
    html_options ||= {}
    html_options[:class] ||= "nav-link"

    if current_page?(options)
      html_options[:class] += " active"
      html_options[:"aria-current"] = "page"
    end

    link_to(name, options, html_options, &block)
  end

  def table_warning_class(condition)
    if condition
      "table-warning"
    end
  end
end

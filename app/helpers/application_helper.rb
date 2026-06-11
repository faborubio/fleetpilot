module ApplicationHelper
  def nav_link_class(path)
    base = "rounded-md px-3 py-1.5 text-sm hover:bg-slate-700"
    current_page?(path) ? "#{base} bg-slate-700 font-medium" : base
  end

  def money(cents)
    return "—" if cents.blank?

    number_to_currency(cents / 100.0)
  end
end

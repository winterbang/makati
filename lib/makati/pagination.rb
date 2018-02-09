module Makati::Pagination

  protected
  def paginate resources = nil
    resources = (resources || @resources).page(params[:page] || 1)
    # default per_page is 25
    if params[:per_page]
      resources = resources.per(params[:per_page])
    end
    resources
  end
end

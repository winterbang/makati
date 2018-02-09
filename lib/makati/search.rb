module Makati::Search

  protected
  def prepare_search_condition
    search_keys = params.keys.map { |key| key.sub('q_', '') if key.start_with? 'q_' }.compact
    return if search_keys.empty?
    search_keys.each_with_object({}) do |key, search_hash|
      # if you can add special condition
      search_hash[key] = params["q_#{key}"]
    end
  end
end

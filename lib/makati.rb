# require "makati/railtie" if defined?(Rails)

require "makati/version"
require "makati/instance_methods"
require "makati/pagination"
require "makati/search"

module Makati
  module Controller
    include InstanceMethods
    include Pagination
    include Search

    def index resources = nil,  &block
      resources = find_resources resources
      # FIX ME 当yield返回空时报错
      resources = yield(resources) if block_given?
      instance_variable_set("@#{resources_name}", paginate(resources.order(id: :desc)))
    end
    alias_method :res_index, :index
    # or in ruby > 2.2, child can call parent method use below method
    # method(:index).super_method.call

    def show
      # resource = find_base_resource
      # instance_variable_set("@#{resource_name(resource)}", resource)
      # if block_given?
      #   yield(resource)
      # end
      instance_variable_set("@#{resource_name}", find_resource)
    end

    def create &block
      form = form_const.new(resource_klass.new)
      if form.validate(params)
        instance_variable_set("@#{resource_name}", form.model)
        if block_given?
          form.save do |hash|
            yield hash
          end
          render json: { message: :successfully_create }, status: 200
        else
          if form.save
            render json: { message: :successfully_create }, status: 200
          else
            render json: { message: form.errors.full_messages.first || form.model.errors.full_messages.first }, status: 422
          end
        end
      else
        render json: { message: form.errors.full_messages.first }, status: 422
      end
    end

    def update resource = nil, &block
      form = form_const.new(resource || resource_klass.find(params[:id]))
      if form.validate(params) && form.save
        resource = form.model
        instance_variable_set("@#{resource_name}", resource)
        if block_given?
          yield resource
        else
          render json: { message: :successfully_update }, status: 200
        end
      else
        render json: { message: form.errors.full_messages.first || form.model.errors.full_messages.first }, status: 422
      end
    end

    def destroy &block
      resource = destroy_resource
      instance_variable_set("@#{resource_name}", resource)
      if block_given?
        yield resource
      else
        render json: { message: :successfully_destroy }, status: 200
      end
    end

    protected

    def find_resources resources = nil
      (resources || resource_klass).ransack(prepare_search_condition).result(distinct: true)
    end

    def find_resource(id = nil)
      id ||= respond_to?(:params) && params.is_a?(ActionController::Parameters) && params[:id]
      resource_klass.find id
    end

    def destroy_resource(id = nil)
      id ||= respond_to?(:params) && params.is_a?(ActionController::Parameters) && params[:id]
      resource_klass.destroy id
    end

    def form_const
      namespaces = self.class.to_s.split("::")
      namespaces.pop
      const = while namespaces.present?
        const = "#{namespaces.join('::')}::#{resource_klass_name}Form::#{action_name.classify}".constantize rescue nil
        break const if const
        namespaces.pop
      end
      # const = "#{namespaces.join('::')}::#{resource_klass_name}Form::#{action_name.classify}".constantize if namespaces.length > 0
      const || "#{resource_klass_name}Form::#{action_name.classify}".try(:constantize)
    end
  end

  class << self
    def config
      return @config if defined?(@config)
      @config = Configuration.new
      @config.style         = :colorful
      @config.length        = 5
      @config.strikethrough = true
      @config.expires_in    = 2.minutes

      if Rails.application
        @config.cache_store = Rails.application.config.cache_store
      else
        @config.cache_store = :mem_cache_store
      end
      @config.cache_store
      @config
    end

    def configure(&block)
      config.instance_exec(&block)
    end
  end

end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.send :include, Makati::Controller
end

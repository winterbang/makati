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
      if block_given?
        resources = yield(resources)
      end
      instance_variable_set("@#{resources_name}", paginate(resources.order(id: :desc)))
    end
    alias_method :res_index, :index
    # or in ruby > 2.2, child can call parent method use below method
    # method(:index).super_method.call

    def show
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
end

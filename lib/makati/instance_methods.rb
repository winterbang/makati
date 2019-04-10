module Makati
  module InstanceMethods
    # name of the singular resource eg: 'user'
    def resource_name
      controller_name.singularize
    end

    # name of the resource collection eg: 'users'
    def resources_name
      controller_name
    end

    # eg: 'User'
    def resource_klass_name
      resource_name.classify
    end

    # eg: User klass
    def resource_klass
      resource_klass_name.constantize
    end

    # ===========

    def klass
      @klass ||= resource_name.classify
    end

    def item_name
      controller_name.singularize
    end

    def items_name
      controller_name
    end

    class << self
      def klass name
        @klass = name.constantize
      end
    end
  end
end

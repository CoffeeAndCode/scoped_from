module ScopedFrom
  
  class Query
    
    TRUE_VALUES = %w( true yes y on 1 ).freeze
    
    attr_reader :params
    
    # Available options are: - :only : to restrict to specified keys.
    #                        - :except : to ignore specified keys.
    #                        - :include_blank : to include blank values
    #                                           (default false).
    def initialize(scope, params, options = {})
      @scope = scope.scoped
      @options = options
      self.params = params
    end
    
    def scope
      scope = @scope
      params.each do |name, value|
        [value].flatten.each do |value|
          scope = scoped(scope, name, value)
        end
      end
      decorate_scope(scope)
    end
    
    protected
    
    def decorate_scope(scope)
      return scope if scope.respond_to?(:query)
      def scope.query
        @__query
      end
      scope.instance_variable_set('@__query', self)
      scope
    end
    
    def scoped(scope, name, value)
      if scope.scope_with_one_argument?(name)
        scope.send(name, value)
      elsif scope.scope_without_argument?(name) && true?(value)
        scope.send(name)
      else
        scope
      end
    end
    
    def params=(params)
      params = params.params if params.is_a?(self.class)
      params = CGI.parse(params.to_s) unless params.is_a?(Hash)
      @params = ActiveSupport::HashWithIndifferentAccess.new
      params.each do |name, value|
        next unless @scope.scopes.key?(name.to_sym)
        if value.is_a?(Array)
          value = value.flatten
          value.delete_if(&:blank?) unless @options[:include_blank]
          if value.many?
            @params[name] = value
          elsif value.any?
            @params[name] = value.first
          end
        elsif @options[:include_blank] || value.present?
          @params[name] = value
        end
      end
      @params.slice!(*[@options[:only]].flatten) if @options[:only].present?
      @params.except!(*[@options[:except]].flatten) if @options[:except].present?
    end
    
    def true?(value)
      TRUE_VALUES.include?(value.to_s.strip.downcase)
    end
    
  end
  
end
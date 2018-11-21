# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(*factory_args, &method)
      const_set(factory_args.shift.capitalize, create_class(*factory_args, &method)) if factory_args.first.is_a? String
      create_class(*factory_args, &method)
    end

    def create_class(*factory_args, &method)
      Class.new do
        attr_accessor *factory_args

        define_method :initialize do |*arg_from_new_class|
          raise ArgumentError, 'Extra arguments passed' unless factory_args.count == arg_from_new_class.count

          factory_args.zip(arg_from_new_class).to_h.each do |variable, value|
            instance_variable_set("@#{variable}", value)
          end
        end

        define_method :[]= do |variable, value|
          return instance_variable_set(instance_variables[variable]), value if variable.is_a? Integer

          instance_variable_set("@#{variable}", value)
        end

        define_method :[] do |variable|
          return instance_variable_get(instance_variables[variable]) if variable.is_a? Integer

          instance_variable_get("@#{variable}")
        end

        define_method :== do |other|
          self.class == other.class && to_a == other.to_a
        end

        define_method :each do |&method|
          to_a.each &method
        end

        define_method :select do |&method|
          to_a.select &method
        end

        define_method :values_at do |*index|
          to_a.values_at *index
        end

        define_method :to_a do
          instance_variables.map { |values| instance_variable_get values }
        end

        define_method :size do
          instance_variables.count
        end

        define_method :members do
          to_h.keys
        end

        define_method :each_pair do |&method|
          to_h.each_pair &method
        end

        define_method :dig do |*arr|
          arr.reduce(to_h) { |memo, char| (memo[char].is_a? NilClass) ? (return nil) : (memo[char]) }
        end

        define_method :to_h do
          factory_args.zip(to_a).to_h
        end

        class_eval &method if block_given?
        alias_method :length, :size
        alias_method :eql?, :==
      end
    end
  end
end

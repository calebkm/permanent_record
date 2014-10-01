require 'active_model'
require 'active_support/core_ext/hash'

class PermanentRecord

  # Get goodies for model_name, etc from ActiveModel.
  # This allows normal Rails path helper generation.
  #
  extend ActiveModel::Naming

  # Constructs a new PermanentRecord instance.
  # Set instance variable and reader based on input hash.
  #
  def initialize attrs={}
    attrs.each do |key, value|
      if valid_attribute? key
        self.instance_variable_set("@#{key}", value) 
        self.class.class_eval{attr_reader key}
      end
    end
  end

  # For working with Rails routing helpers.
  # Override in your PermanentRecord class to adjust URLs.
  #
  def to_param
    self.id
  end

  # Overrides equality to match ids.
  #
  def == record
    self.id == record.try(:id)
  end

  class << self
    # Returns collection of all PermanentRecord instances.
    #
    # Example:
    #   >> Model.all
    #   => [@model1, @model2, ...]
    #
    def all
      data.map{|d| self.new(d)}
    end

    # Find instance given id.
    # Returns instance if found; nil otherwise.
    #
    # Example:
    #   >> Model.find(42)
    #   => @model
    #
    def find id
      self.find_by_attribute(:id, id)
    end

    # Find instance given attribute name and expected value.
    # Returns instance if found; nil otherwise.
    #
    # Example:
    #   >> Model.find_by_attribute(:bacon, 'chunky')
    #   => @model
    #
    def find_by_attribute key, value
      found = data.find{|d| d[key.to_sym].to_s == value.to_s}
      self.new(found) if found
    end

    # Find instance(s) given hash of attribute key/values.
    # Returns all instances if found; empty array otherwise.
    #
    # Example:
    #   >> Model.where(bacon: 'chunky', cats: 'calico')
    #   => [@model1, @model2, ...]
    #
    def where *attrs
      keys = attrs.first.keys
      found = data.map{|d| d if d.reject{|key,_| !keys.include?(key)} == attrs.first}
      found.compact.map{|f| self.new(f)}
    end

    # Oh, just for fun let's metaprogram some method missing!
    # Provides 'find_by_<attr>' finders if you don't like 'where'.
    # Returns instance if found; nil otherwise.
    #
    # Example:
    #   >> Model.find_by_bacon('chunky')
    #   => @model
    #
    def method_missing(method, *arguments, &block)
      match = method.to_s.match(/^find_by_(.*)$/)
      if match && valid_attribute?($1.to_sym)
        find_by_attribute($1.to_sym, arguments.first)
      else
        super
      end
    end
  end

protected

  # Check if attribute name is valid.
  #
  def valid_attribute? key
    self.class.valid_attribute?(key)
  end

  class << self
    # Declares source for PermanentRecord class data.
    # PermanentRecord pretty much just wants to source any ol' array of hashes.
    # If not declared, it'll default to a pluralized model name constant.
    # ie: If your model is called MyModel, this'll try and find MY_MODELS.
    #
    # The default example, with NO source defined:
    #   class MyModel < PermanentRecord
    #   end
    #
    # Example with source constant explicitly defined:
    #   class MyModel < PermanentRecord
    #     source SOME_CONSTANT
    #   end
    #
    # Another example with a source YAML file explicitly defined:
    #  class MyModel < PermanentRecord
    #    source YAML.load(File.read('path/to/yaml/file.yml'))
    #  end
    #
    # I doubt you'd want to define your source as an explicit array of hash, 
    # but just to drive home this "any array of hashes" idea here's an example:
    #  class MyModel < PermanentRecord
    #    source [{eyes: 'blue', hair: 'blonde'}, {eyes: 'brown', hair: 'green'}]
    #  end
    #
    def source data=nil
      @_data = format_data data
    end

    # Retrieve or load raw data.
    #
    def data
      @_data ||= data_from_constant
    end

    # Auto load data from constant; pluralized model name
    # ie: If your model is called ZooKeeper, this will try and
    #     auto load a constant called ZOO_KEEPERS. You can put that
    #     constant anywhere you want ... like in the model, or in
    #     a constants.rb file, or maybe a zoo_keeprs.rb file.
    #
    def data_from_constant
      data = eval(self.name.to_s.underscore.pluralize.upcase)
      format_data data
    end

    # Add sequential id to all records.
    # This can be overwritten if an id is specified in the data.
    # CAUTION! If defining your own ids please make sure they're unique!
    #
    def format_data data
      data = data.each_with_index.map{|d, i| {id: i+1}.merge(d)}
      data.each(&:symbolize_keys!)
    end

    # Retrieve or load model attributes.
    #
    def attributes
      @_attributes ||= attributes_from_data
    end

    # Find attributes based on first data item keys
    # This might be something worth explicitly stating in an
    # 'attributes' config or something... but for now I'm going
    # with the lazy way out, and we'll just check the first data item.
    # So please be sure to have well formed data!
    #
    def attributes_from_data
      data.first.keys
    end

    # Check if attribute name is valid.
    #
    def valid_attribute? key
      attributes.include?(key)
    end
  end

end
##
# Used to implement Module#autoload.

class Autoload
  attr_reader :name
  attr_reader :scope
  attr_reader :path
  attr_reader :original_path

  def initialize(name, scope, path)
    @name = name
    @scope = scope
    @original_path = path
    @path, = __split_path__(path)
    Autoload.add(self)
  end

  # When any code that finds a constant sees an instance of Autoload as its match,
  # it calls this method on us
  def call
    require(path)
    scope.const_get(name)
  end

  # Called by Autoload.remove
  def discard
    scope.__send__(:remove_const, name)
  end

  # Class methods
  class << self
    def autoloads
      @autoloads ||= {}
    end

    # Called by Autoload#initialize
    def add(al)
      autoloads[al.path] = al
    end

    # Called by require; see kernel/core/compile.rb
    def remove(path)
      al = autoloads.delete(path)
      al.discard if al
    end
  end
end

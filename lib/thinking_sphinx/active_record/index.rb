class ThinkingSphinx::ActiveRecord::Index < Riddle::Configuration::Index
  attr_reader :reference
  attr_writer :definition_block

  def initialize(reference, options = {})
    @reference = reference
    @docinfo   = :extern

    super reference.to_s
  end

  def append_source
    ThinkingSphinx::ActiveRecord::SQLSource.new(
      model, :offset => offset
    ).tap do |source|
      sources << source
    end
  end

  def interpret_definition!
    return if @interpreted_definition || @definition_block.nil?

    ThinkingSphinx::ActiveRecord::Interpreter.translate! self, @definition_block
    @interpreted_definition = true
  end

  def model
    @model ||= reference.to_s.camelize.constantize
  end

  def offset
    @offset ||= config.next_offset(reference)
  end

  def render
    self.class.settings.each do |setting|
      value = config.settings[setting.to_s]
      send("#{setting}=", value) unless value.nil?
    end

    interpret_definition!

    @path ||= config.indices_location.join(name)

    super
  end

  private

  def config
    ThinkingSphinx::Configuration.instance
  end
end

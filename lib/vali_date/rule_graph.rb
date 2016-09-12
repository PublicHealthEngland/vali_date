module ValiDate
  class RuleGraph
    def initialize
      @nodes  = {}
      @edges  = []
    end

    def add_rule(source, target, options = {})
      source = get_node(source)
      target = get_node(target)

      @edges << [source, target, options]
    end

    def populate(attributes)
      @nodes.each { |attr, _value| @nodes[attr] = nil }

      attributes.each do |attr, value|
        attr = attr.to_sym
        next unless @nodes.key?(attr)

        @nodes[attr] = value
      end

      self
    end

    def condense!
      @nodes.each do |node, value|
        next unless value.blank?

        incoming = @edges.select { |_source, dest, _opts| dest == node }
        outgoing = @edges.select { |source, _dest, _opts| source == node }

        (incoming + outgoing).each { |edge| @edges.delete(edge) }

        incoming.each do |source, _dn, options1|
          outgoing.each do |_sn, dest, options2|
            @edges << [source, dest, merge_options(options1, options2)]
          end
        end
      end
    end

    private

    # vali_date(:birth, before: :death, strict: true, only_calendar: true)
    # vali_date(:birth, at_least: 18.years, before: :drink)
    def merge_options(options1, options2)
      {}.tap do |options|
        options[:strict] = options1[:strict] || options2[:strict]

        if options1[:at_least] || options2[:at_least]
          options[:at_least] = options1[:at_least].to_i + options2[:at_least].to_i
        end

        if options1[:at_most] && options2[:at_most]
          options[:at_most] = options1[:at_most] + options2[:at_most]
        end
      end
    end

    def get_node(label)
      label = label.to_sym

      @nodes.keys.detect { |node| label == node } ||
        label.tap { |l| @nodes[l] = nil }
    end
  end
end

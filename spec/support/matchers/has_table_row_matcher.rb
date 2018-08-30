module Support
  module Matchers
    def have_table_row_contents(*text, position: nil)
      HasTableRowContents.new(*text, position: position)
    end

    class HasTableRowContents
      def initialize(*text, position: nil)
        @position = position
        @text = text
      end

      def matches?(page)
        @page = page

        has_matching_row?
      end

      def description
        "have row with #{contents}"
      end

      def failure_message
        "Expected page to have table row with #{contents}, but it did not"
      end

      def failure_message_when_negated
        "Expected page not to have table row with #{contents}, but it did"
      end

      def contents
        text.map { |t| "'#{t}'" }.join(', ')
      end

      private

      attr_reader :page, :text, :position

      def row_matcher
        if position.nil?
          'tr'
        else
          "tr:nth-child(#{position})"
        end
      end

      def has_matching_row?
        page.find(row_matcher, text: /#{text.join(".*")}/)
      rescue Capybara::ElementNotFound
      end
    end
  end
end

module LiteRGSS
  class Text
    # Set a multiline text
    # @param value [String] Multiline text that should be ajusted to be display on multiple lines
    def multiline_text=(value)
      sw = text_width(' ') + 1 # /!\ 1 added for adjsutment, idk if correct or not.
      x = 0
      max_width = width
      words = ''
      value.split(/ /).compact.each do |word|
        if word.include?("\n")
          word, next_word = word.split("\n")
          w = text_width(word)
          words << "\n" if x + w > max_width
          x = 0
          words << word << "\n" << next_word << ' '
          x += (text_width(next_word) + sw)
        else
          w = text_width(word)
          if x + w > max_width
            x = 0
            words << "\n"
          end
          words << word << ' '
          x += (w + sw)
        end
      end
      self.text = ' ' if words == text
      self.text = words
    end
  end
end

module KataBankOcr

  class OcrFile
    attr_reader :lines # Line instances
    attr_reader :path # Path to the text file.
    attr_reader :file_lines # Strings from the text file.

    def initialize(path)
      @path = path
      @file_lines = File.new(path).readlines

      split_out_lines
    end

    def to_s
      lines.map(&:to_s).join "\n"
    end

    def parsed_path
      "#{path.split(".")[0...-1].join(".")}.parsed"
    end

    def write_parsed_file
      File.open(parsed_path,"w") do |parsed_file|
        lines.map(&:to_s).each do |s|
          parsed_file.puts s
        end
      end
    end

    private

    def split_out_lines
      @lines = []
      @file_lines.each_slice(4) do |lines|
        @lines.push Line.new(*lines[0..2])
      end
    end
  end

  class Line
    NUMBER_OF_DIGITS = 9
    attr_reader :digits
    attr_reader :strings

    def initialize(*strings)
      @strings = strings

      split_out_digits
    end

    def split_out_digits
      @digits = []
      (0...NUMBER_OF_DIGITS).each do |i|
        start = i * Digit::WIDTH
        finish = start + Digit::WIDTH
        digits.push Digit.new(*(0..2).map {|j| strings[j][start...finish]})
      end
    end
    private :split_out_digits

    def illegible?
      digits.any? &:illegible?
    end

    def legible?
      not illegible?
    end

    def to_i
      result = 0
      digits.each do |digit|
        result *= 10
        result += digit.to_digit
      end
      result
    end

    def to_s
      if illegible?
        "#{digits.map(&:to_c).join} ILL"
      elsif invalid?
        "%09d ERR" % to_i
      else
        "%09d" % to_i
      end
    end

    def checksum
      result = 0
      (0..9).each do |i|
        result += digits.reverse[i].to_i * (i+1)
      end
      result % 11
    end

    def valid?
      checksum == 0
    end

    def invalid?
      not valid?
    end

    def == other
      self.digits == other.digits
    end

    class << self
      def new_from_digits(*digits)
        strings = (0..2).map do |i|
          digits.map {|d| d.strings[i]}.join
        end
        Line.new *strings
      end

      def new_from_number(number)
        new_from_digits *number.to_s.chars.map {|char| DIGITS[char.to_i]}
      end
    end
  end

  class Digit
    WIDTH = 3
    attr_reader :strings

    def initialize(*strings)
      @strings = strings
    end

    def == other
      self.strings == other.strings
    end

    def is_digit? n
      self == DIGITS[n]
    end

    def to_digit
      (0..9).each do |n|
        return n if is_digit? n
      end
      return nil # Illegible
    end

    def to_i
      to_digit
    end

    def legible?
      to_digit != nil
    end

    def illegible?
      not legible?
    end

    def to_c
      if legible?
        to_digit.to_s
      else
        "?"
      end
    end
  end

  ZERO  = Digit.new(" _ ", "| |", "|_|")
  ONE   = Digit.new("   ", "  |", "  |")
  TWO   = Digit.new(" _ ", " _|", "|_ ")
  THREE = Digit.new(" _ ", " _|", " _|")
  FOUR  = Digit.new("   ", "|_|", "  |")
  FIVE  = Digit.new(" _ ", "|_ ", " _|")
  SIX   = Digit.new(" _ ", "|_ ", "|_|")
  SEVEN = Digit.new(" _ ", "  |", "  |")
  EIGHT = Digit.new(" _ ", "|_|", "|_|")
  NINE  = Digit.new(" _ ", "|_|", " _|")

  DIGITS = [ZERO,ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,NINE]

  ILLEGIBLE = Digit.new(
    "!!!",
    "!!!",
    "!!!")
end
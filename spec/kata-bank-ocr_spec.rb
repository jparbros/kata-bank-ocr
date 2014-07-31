require 'spec_helper'

require 'kata-bank-ocr'
include KataBankOcr

describe OcrFile do
  before :each do
    @ocr_file = OcrFile.new("spec/files/many.txt")
  end

  it "can be instantiated" do
    @ocr_file.should be_a OcrFile
  end

  describe :file_lines do
    it "contains the text lines" do
      @ocr_file.file_lines.should be_an Array
      @ocr_file.file_lines.each do |file_line|
        file_line.should be_a String
      end
    end
  end

  describe :lines do
    it "contains the parsed lines" do
      @ocr_file.lines.should be_an Array
      @ocr_file.lines.each do |line|
        line.should be_a Line
      end
    end

    it "correctly splits the lines" do
      @ocr_file.lines[0].to_i.should == 0
      @ocr_file.lines[1].to_i.should == 111111111
      @ocr_file.lines[2].to_i.should == 222222222
      @ocr_file.lines[3].to_i.should == 333333333
      @ocr_file.lines[4].to_i.should == 444444444
      @ocr_file.lines[5].to_i.should == 555555555
      @ocr_file.lines[6].to_i.should == 666666666
      @ocr_file.lines[7].to_i.should == 777777777
      @ocr_file.lines[8].to_i.should == 888888888
      @ocr_file.lines[9].to_i.should == 999999999
      @ocr_file.lines[10].to_i.should == 123456789
    end
  end

  describe :to_s do
    it "works with illegible inputs" do
      @file_ex3 = OcrFile.new("spec/files/ex3.txt")
      @file_ex3.to_s.should == [
        "000000051",
        "49006771? ILL",
        "1234?678? ILL"
      ].join("\n")
    end
  end
end

describe Line do
  before :all do
    @line = Line.new(
      "    _  _     _  _  _  _  _  ",
      "  | _| _||_||_ |_   ||_||_| ",
      "  ||_  _|  | _||_|  ||_| _| ")
    @valid_number = 457508000
    @valid = Line.new_from_number @valid_number
    @invalid_number = 664371495
    @invalid = Line.new_from_number @invalid_number
    @illegible = Line.new_from_digits ONE,TWO,THREE,FOUR,ILLEGIBLE,SIX,SEVEN,EIGHT,NINE
  end

  it "can be instantiated" do
    @line.should be_a Line
  end

  describe :digits do
    it "splits out the individual digits" do
      @line.digits.should be_a Array
      @line.digits.length.should == 9
      @line.digits[0].should == ONE
      @line.digits[1].should == TWO
      @line.digits[2].should == THREE
      @line.digits[3].should == FOUR
      @line.digits[4].should == FIVE
      @line.digits[5].should == SIX
      @line.digits[6].should == SEVEN
      @line.digits[7].should == EIGHT
      @line.digits[8].should == NINE
    end
  end

  describe :new_from_digits do
    it "builds a new line from digits" do
      Line.new_from_digits(ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,NINE)
        .to_i.should == 123456789
    end
  end

  describe :new_from_number do
    it "builds a new line from a number" do
      Line.new_from_number(123456789).should == @line
    end
  end

  describe :to_i do
    it "works" do
      @line.to_i.should == 123456789
    end
  end

  describe :to_s do
    it "works with valid input" do
      @valid.to_s.should == "#{@valid_number}"
    end

    it "works with invalid input" do
      @invalid.to_s.should == "#{@invalid_number} ERR"
    end

    it "works with illegible input" do
      @illegible.to_s.should == "1234?6789 ILL"
    end
  end

  describe :valid? do
    it "returns true when the line passes the checksum" do
      @valid.should be_valid
    end

    it "returns false when the line fails the checksum" do
      @invalid.should_not be_valid
    end
  end
end

describe Digit do
  before :all do
    @illegible = Digit.new("abc","def","ghi")
  end

  it "can be instantiated" do
    Digit.new(" _ ","| |","|_|").should be_a Digit
  end

  describe :== do
    it "works" do
      ZERO.should == Digit.new(
        " _ ",
        "| |",
        "|_|")
    end
  end

  describe :is_digit? do
    it "returns true for the correct n" do
      ZERO.should be_is_digit 0
      ONE.should be_is_digit 1
      TWO.should be_is_digit 2
      THREE.should be_is_digit 3
      FOUR.should be_is_digit 4
      FIVE.should be_is_digit 5
      SIX.should be_is_digit 6
      SEVEN.should be_is_digit 7
      EIGHT.should be_is_digit 8
      NINE.should be_is_digit 9
    end

    it "handles illegible digits" do
      @illegible.should_not be_is_digit 7
    end
  end

  describe :to_digit do
    it "returns the correct digit" do
      ZERO.to_digit.should == 0
      ONE.to_digit.should == 1
      TWO.to_digit.should == 2
      THREE.to_digit.should == 3
      FOUR.to_digit.should == 4
      FIVE.to_digit.should == 5
      SIX.to_digit.should == 6
      SEVEN.to_digit.should == 7
      EIGHT.to_digit.should == 8
      NINE.to_digit.should == 9
    end

    it "returns nil on illegible" do
      @illegible.to_digit.should be nil
    end
  end
end
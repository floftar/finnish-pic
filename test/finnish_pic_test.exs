defmodule FinnishPicTest do
  use ExUnit.Case

  test "Anna Suomalainen’s valid PIC (known test person)" do
    {:ok, result} = FinnishPic.validate("131052-308T")
    assert result.birth_date == ~D[1952-10-13]
    assert result.gender == :female
    assert result.temporary_id == false
  end

  test "Siiri Suomalainen’s valid PIC (known test person)" do
    {:ok, result} = FinnishPic.validate("240147-632T")
    assert result.birth_date == ~D[1947-01-24]
    assert result.gender == :female
    assert result.temporary_id == false
  end

  test "Matti Matkailija's valid PIC (known test person)" do
    {:ok, result} = FinnishPic.validate("010150-1130")
    assert result.birth_date == ~D[1950-01-01]
    assert result.gender == :male
    assert result.temporary_id == false
  end

  test "valid PICs born in the 1800s" do
    {:ok, result} = FinnishPic.validate("291110+948R")
    assert result.birth_date == ~D[1810-11-29]
    assert result.gender == :female
    assert result.temporary_id == true

    {:ok, result} = FinnishPic.validate("030690+917K")
    assert result.birth_date == ~D[1890-06-03]
    assert result.gender == :male
    assert result.temporary_id == true
  end

  test "valid PICs born in the 1900s" do
    {:ok, result} = FinnishPic.validate("010181-900C")
    assert result.birth_date == ~D[1981-01-01]
    assert result.gender == :female
    assert result.temporary_id == true

    {:ok, result} = FinnishPic.validate("311299-9872")
    assert result.birth_date == ~D[1999-12-31]
    assert result.gender == :male
    assert result.temporary_id == true
  end

  test "valid PICs born in the 2000s" do
    {:ok, result} = FinnishPic.validate("270201A964C")
    assert result.birth_date == ~D[2001-02-27]
    assert result.gender == :female
    assert result.temporary_id == true

    {:ok, result} = FinnishPic.validate("111014A9458")
    assert result.birth_date == ~D[2014-10-11]
    assert result.gender == :male
    assert result.temporary_id == true
  end

  test "valid PIC with February 29th" do
    {:ok, result} = FinnishPic.validate("290200A935F")
    assert result.birth_date == ~D[2000-02-29]
    assert result.gender == :male
    assert result.temporary_id == true
  end

  test "valid PIC with smallest possible individual number 002" do
    {:ok, result} = FinnishPic.validate("010101+002S")
    assert result.birth_date == ~D[1801-01-01]
    assert result.gender == :female
    assert result.temporary_id == false
  end

  test "too short" do
    expect_to_fail("", :too_short)
    expect_to_fail("123456-123", :too_short)
  end

  test "too long" do
    expect_to_fail("123456-12345", :too_long)
  end

  test "extra spaces before or after" do
    expect_to_fail(" 010203-308T", :too_long)
    expect_to_fail("010203-308T ", :too_long)
  end

  test "invalid date format" do
    expect_to_fail("ABCDEF-123T", :invalid_format)
    expect_to_fail("01CDEF-123T", :invalid_format)
    expect_to_fail("0102EF-123T", :invalid_format)
  end

  test "invalid date" do
    expect_to_fail("001052-123T", :invalid_date)
    expect_to_fail("010052-123T", :invalid_date)

    # non-leap year
    expect_to_fail("290297-123T", :invalid_date)

    # leap year
    expect_to_fail("300296-123T", :invalid_date)
  end

  test "invalid century" do
    expect_to_fail("131052a123T", :invalid_format)
    expect_to_fail("131052B123T", :invalid_format)
    expect_to_fail("010203*123T", :invalid_format)
  end

  test "invalid individual number" do
    expect_to_fail("010203-000T", :invalid_individual_number)
    expect_to_fail("010203-001T", :invalid_individual_number)
  end

  test "invalid control character" do
    expect_to_fail("010203-123G", :invalid_format)
    expect_to_fail("010203-123Z", :invalid_format)
    expect_to_fail("010203-123-", :invalid_format)
    expect_to_fail("010203-123!", :invalid_format)
  end

  test "invalid format" do
    expect_to_fail("2019-1-123A", :invalid_format)
    expect_to_fail("-04-21-123A", :invalid_format)
    expect_to_fail("010203-1.2A", :invalid_format)
    expect_to_fail("010203-.12A", :invalid_format)
  end

  test "invalid type" do
    assert_raise FunctionClauseError, fn ->
      FinnishPic.validate(true)
    end

    assert_raise FunctionClauseError, fn ->
      FinnishPic.validate(~c{131052-308T})
    end
  end

  def expect_to_fail(pic, expected) do
    {:error, reason} = FinnishPic.validate(pic)
    assert reason == expected
  end
end

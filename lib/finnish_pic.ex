defmodule FinnishPic do
  @moduledoc """
  Finnish Personal Identity Code Validator.
  """

  @code_length 11

  @control_chars ~c{0123456789ABCDEFHJKLMNPRSTUVWXY}

  @remainder_to_control @control_chars
                        |> Enum.with_index(0)
                        |> Enum.map(fn {k, v} -> {v, <<k::utf8>>} end)
                        |> Map.new()

  defstruct(
    birth_date: nil,
    gender: nil,
    temporary_id: false
  )

  @doc """
  Validates Finnish Personal Identity Code.

  ## Examples

      iex> FinnishPic.validate("131052-308T")
      {:ok, %FinnishPic{
        birth_date: ~D[1952-10-13],
        gender: :female,
        temporary_id: false
      }}

      iex> FinnishPic.validate("931052-308T")
      {:error, :invalid_date}

  ## Validation errors
  - :too_short
  - :too_long
  - :invalid_format
  - :invalid_date
  - :invalid_individual_number
  - :invalid_control_char
  """
  def validate(pic) when is_binary(pic) do
    with :ok <- check_length(pic),
         {:ok, parts} <- split_to_parts(pic),
         {:ok, birth_date} <- parse_date(parts),
         {:ok, gender, temporary_id} <- parse_number(parts),
         :ok <- check_control_char(parts) do
      {:ok,
       %FinnishPic{
         birth_date: birth_date,
         gender: gender,
         temporary_id: temporary_id
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp check_length(pic) do
    len = pic |> String.length()

    cond do
      len < @code_length ->
        {:error, :too_short}

      len > @code_length ->
        {:error, :too_long}

      true ->
        :ok
    end
  end

  defp split_to_parts(pic) do
    chars = @control_chars |> List.to_string()
    pattern = ~r/^(\d\d)(\d\d)(\d\d)([+-A])(\d{3})([#{chars}])$/

    with [_, day, month, year, century, number, control] <- Regex.run(pattern, pic) do
      {:ok,
       %{
         :day => day,
         :month => month,
         :year => year,
         :century => century,
         :number => number,
         :control_char => control
       }}
    else
      nil -> {:error, :invalid_format}
    end
  end

  defp parse_date(parts) do
    four_digit_year =
      case parts.century do
        "+" ->
          "18#{parts.year}"

        "-" ->
          "19#{parts.year}"

        "A" ->
          "20#{parts.year}"
      end

    case Date.from_iso8601("#{four_digit_year}-#{parts.month}-#{parts.day}") do
      {:ok, birth_date} ->
        {:ok, birth_date}

      _ ->
        {:error, :invalid_date}
    end
  end

  defp parse_number(parts) do
    number = parts.number |> String.to_integer()

    cond do
      number < 2 ->
        {:error, :invalid_individual_number}

      true ->
        {
          :ok,
          if(rem(number, 2) == 0, do: :female, else: :male),
          number >= 900
        }
    end
  end

  defp check_control_char(parts) do
    remainder =
      String.graphemes("#{parts.day}#{parts.month}#{parts.year}#{parts.number}")
      |> Enum.join()
      |> String.to_integer()
      |> rem(length(@control_chars))

    if @remainder_to_control[remainder] == parts.control_char,
      do: :ok,
      else: {:error, :invalid_control_char}
  end
end

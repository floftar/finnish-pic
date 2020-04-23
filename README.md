# Finnish Personal Identity Code Validator

Validates Finnish Personal Identity Code (Finnish: henkilötunnus / HETU).

## Format of Code

A code consists of eleven characters of the form DDMMYYCZZZQ, where
DDMMYY is the day, month and year of birth, C the century sign, ZZZ
the individual number and Q the control character (checksum).

Individual numbers 900–999 are used for temporary personal identification.

## Examples

    iex> FinnishPic.validate("131052-308T")
    {:ok, %FinnishPic{
      birth_date: ~D[1952-10-13],
      gender: :female,
      temporary_id: false
    }}

    iex> FinnishPic.validate("931052-308T")
    {:error, :invalid_date}

## Notes

Implementation only validates the Personal Identity Code and does not tell if
it is really used.

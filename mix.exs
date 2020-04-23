defmodule FinnishPic.MixProject do
  use Mix.Project

  def project do
    [
      app: :finnish_pic,
      version: "1.0.0",
      package: package(),
      description: "Finnish Personal Identity Code Validator"
    ]
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fbergr/finnish-pic"}
    ]
  end
end

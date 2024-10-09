defmodule ResvgTest do
  @moduledoc """
  Documentation for `ResvgTest`.
  """

  # def extract_files(destination) do
  #   path = Path.join(destination, "resvg-linux-x86_64.tar.gz")
  #   :ok = :erl_tar.extract(path, [:compressed, cwd: destination])
  #   # File.rm!(path)
  # end

  # def clean_up_targz(destination) do
  #   path = Path.join(destination, "resvg-linux-x86_64.tar.gz")
  #   File.rm!(path)
  # end

  # def download_resvg_all_versions() do
  #   for i <- 35..44 do
  #     vsn = "0.#{i}.0"
  #     url = "https://github.com/RazrFalcon/resvg/releases/download/" <>
  #       "v#{vsn}/resvg-linux-x86_64.tar.gz"

  #     destination = "priv/bin/v#{vsn}"
  #     File.mkdir_p!(destination)

  #     # download_and_extract_targz(url, destination)
  #     extract_files(destination)
  #     clean_up_targz(destination)
  #   end

  #   :ok
  # end
end

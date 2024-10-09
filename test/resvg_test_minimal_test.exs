defmodule ResvgTestMinimal do
  use ExUnit.Case
  doctest ResvgTest

  @resvg_versions for i <- 20..44, do: "v0.#{i}.0"

  defp download_and_extract_targz(url, destination) do
    archive_path = Path.join(destination, "resvg-linux-x86_64.tar.gz")
    response = :httpc.request(:get, {url, []}, [], [])
    case response do
      {:ok, {{_, 200, 'OK'}, _headers, body}} ->
        # Write the archive
        File.write!(archive_path, body)
        # Unpack the archive contents (which are only the binary)
        :ok = :erl_tar.extract(archive_path, [:compressed, cwd: destination])
        # Remove the archive
        File.rm!(archive_path)

      _ ->
        raise "Error while attempting to download \"#{url}\""
    end
  end

  setup_all do
      File.mkdir_p!("priv/bin")

      for vsn <- @resvg_versions do
        destination = "priv/bin/#{vsn}"

        unless File.exists?(destination) do
          File.mkdir_p!(destination)

          url = "https://github.com/RazrFalcon/resvg/releases/download/" <>
            "#{vsn}/resvg-linux-x86_64.tar.gz"

          download_and_extract_targz(url, destination)

          :timer.sleep(500)
      end
    end

    :ok
  end

  test "reproduces bug" do
    dpi = 300
    cwd = File.cwd!()

    resvg_options = [
      resources_dir: ".",
      skip_system_fonts: true,
      font_dirs: ["priv/fonts"],
      dpi: dpi
    ]

    png_nif_path = Path.absname("test/results/minimal_nif.png", cwd)
    minimal_input_path = Path.absname("test/svg/minimal.svg", cwd)

    # The minimal text that triggers the bug
    minimal_svg_binary = File.read!(minimal_input_path)

    png_resvg_nif = Resvg.svg_string_to_png(minimal_svg_binary, png_nif_path, resvg_options)

    png_nif_reference_data = File.read!(png_nif_path)

    results =
      for vsn <- @resvg_versions do
        File.mkdir_p!("test/results/#{vsn}")

        rsvg_cmd_path = Path.absname("priv/bin/#{vsn}/resvg", cwd)
        png_cmdline_path = Path.absname("test/results/#{vsn}/minimal_cmdline.png", cwd)

        arguments = [
          minimal_input_path,
          png_cmdline_path,
          "--dpi",
          to_string(dpi),
          "--resources-dir",
          ".",
          "--skip-system-fonts",
          "--use-fonts-dir",
          "priv/fonts"
        ]

        {_result, 0} = System.cmd(rsvg_cmd_path, arguments, cd: ".")

        equal? = (png_resvg_nif == File.read!(png_cmdline_path))

        {vsn, equal?, png_cmdline_path}
      end

    results = [{"nif", true, png_nif_path} | results]

    key_fun = fn {_vsn, _result, path} -> File.read!(path) end
    value_fun = fn {vsn, _results, _path} -> vsn end

    groups = Enum.group_by(results, key_fun, value_fun)

    if map_size(groups) > 1 do
      list =
        for {_png, versions} <- groups do
          ["- ", Enum.intersperse(versions, ", "), "\n"]
        end

      raise """
        A number of outputs was returned by the different resvg versions.
        The versions grouped by output are the following:

        #{list}
        """
    else
      :ok
    end
  end
end

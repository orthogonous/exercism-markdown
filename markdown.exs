defmodule Markdown do
  @doc """
    Parses a given string with Markdown syntax and returns the associated HTML for that string.

    ## Examples

    iex> Markdown.parse("This is a paragraph")
    "<p>This is a paragraph</p>"

    iex> Markdown.parse("#Header!\n* __Bold Item__\n* _Italic Item_")
    "<h1>Header!</h1><ul><li><em>Bold Item</em></li><li><i>Italic Item</i></li></ul>"
  """
  @spec parse(String.t()) :: String.t()
  def parse(m) do
    process(m)
  end

  defp process(string) do
    String.split(string, "\n")
    |> Enum.map(fn x -> String.graphemes(x) |> process([]) end)
    |> Enum.join()
  end

  defp process(["_", "_", head | tail], acc) do
    process(tail, [head, insert(:bold_open) | acc])
  end

  defp process(["_", "_" | tail], acc) do
    process(tail, [insert(:bold_close) | acc])
  end

  defp process(["_", head | tail], acc) do
    process(tail, [head, insert(:italic_open) | acc], :open)
  end

  defp process(["_"], acc) do
    process([], [insert(:italic_close) | acc])
  end

  defp process(["#", " " | tail], acc) do
    process_header(tail, 1, acc)
  end

  defp process(["#" | tail], acc) do
    process_header(tail, 1, acc)
  end

  defp process([head | tail], acc) do
    process(tail, [head | acc])
  end

  defp process([], acc) do
    string = acc |> Enum.reverse()
    [insert(:paragraph_open), string, insert(:paragraph_close)] |> Enum.join()
  end

  defp process([head, "_" | tail], acc, :open) do
    process(tail, [insert(:italic_close), head | acc])
  end

  defp process([head | tail], acc, :open) do
    process(tail, [head | acc])
  end

  defp process_header(["#", " " | tail], count, acc) do
    process_header(tail, count + 1, acc)
  end

  defp process_header(["#" | tail], count, acc) do
    process_header(tail, count + 1, acc)
  end

  defp process_header([head | tail], count, acc) do
    process_header(tail, count, [head | acc])
  end

  defp process_header([], count, acc) do
    header = acc |> Enum.reverse()
    [insert(:header_open, count), header, insert(:header_close, count)] |> Enum.join()
  end

  defp insert(:italic_open), do: string2list("<em>")
  defp insert(:italic_close), do: string2list("</em>")
  defp insert(:bold_open), do: string2list("<strong>")
  defp insert(:bold_close), do: string2list("</strong>")
  defp insert(:paragraph_open), do: string2list("<p>")
  defp insert(:paragraph_close), do: string2list("</p>")
  defp insert(:header_open, c), do: string2list("<h" <> to_string(c) <> ">")
  defp insert(:header_close, c), do: string2list("</h" <> to_string(c) <> ">")

  defp string2list(s), do: String.graphemes(s)
end

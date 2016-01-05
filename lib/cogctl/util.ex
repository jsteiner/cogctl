defmodule Cogctl.Util do

  @tab_size 4

  def enum_to_set(items) do
    Enum.reduce(items, MapSet.new(), &MapSet.put(&2, &1))
  end

  def spacer_for(values, attr_name) do
    sizes = Enum.map(values, &(String.length("#{Map.get(&1, attr_name)}")))
    max_line = Enum.max(sizes)
    tabs = Kernel.div(max_line - Enum.min(sizes), @tab_size)
    fn(text) ->
      tabs = if max_line - String.length(text) < 4 do
        Enum.max([tabs - 1, 1])
      else
        tabs
      end
      text <> Enum.join(make_tabs(tabs, []), "")
    end
  end

  defp make_tabs(0, tabs), do: tabs
  defp make_tabs(count, tabs) do
    make_tabs(count - 1, ["\t"|tabs])
  end

end

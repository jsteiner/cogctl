defmodule Cogctl.Actions.BundleList do

  use Cogctl.Action, "bundle list"
  alias Cogctl.CogApi
  alias Cogctl.Util

  def option_spec() do
    [{:bundle, ?b, 'bundle', :string, 'Bundle id'},
     {:relays, ?r, 'relays', :boolean, 'Include list of relay ids when listing bundle details'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_list(:proplists.get_value(:bundle, options), client, options)
      {:error, error} ->
        IO.puts "#{error["error"]}"
    end
  end

  defp do_list(:undefined, client, _options) do
    case CogApi.list_all_bundles(client) do
      {:ok, resp} ->
        bundles = resp["bundles"]
        for bundle <- bundles do
          id = bundle["id"]
          name = bundle["name"]
          installed = bundle["inserted_at"]
          IO.puts "Bundle: #{name} (id: #{id})\nInstalled: #{installed}\n"
        end
        :ok
      {:error, resp} ->
        {:error, resp}
    end
  end
  defp do_list(bundle_id, client, options) do
    case get_relays(client, bundle_id, options) do
      {:ok, formatted_relays} ->
        case CogApi.bundle_info(client, bundle_id) do
          {:ok, resp} ->
            id = get_in(resp, ["bundle", "id"])
            name = get_in(resp, ["bundle", "name"])
            installed = get_in(resp, ["bundle", "inserted_at"])
            cmdout = format_commands(get_in(resp, ["bundle", "commands"]))
            msg = "Bundle: #{name} (id: #{id})\nInstalled: #{installed}\n" <>
                  formatted_relays <> cmdout
            IO.puts msg
            :ok
          {:error, error} ->
            IO.puts error["error"]
            :error
        end
      {:error, error} ->
        IO.puts error["error"]
        :error
    end
  end

  defp get_relays(client, bundle_id, options) do
    if :proplists.get_value(:relays, options, false) == true do
      case CogApi.relays_for_bundle(client, bundle_id) do
        {:ok, resp} ->
          {:ok, format_relays(get_in(resp, ["bundle", "relays"]))}
        error ->
          error
      end
    else
      {:ok, ""}
    end
  end

  defp format_commands([]) do
    "\nCommands (0)\n"
  end
  defp format_commands(commands) do
    spacer = Util.spacer_for(commands, "name")
    clist = Enum.map(commands, &(" #{spacer.(&1["name"])}(id: #{&1["id"]})"))
    |> Enum.join("\n")
    "\nCommands (#{length(commands)})\n" <> clist
  end

  defp format_relays(nil), do: ""
  defp format_relays([]), do: "\nRelays (0)\n"
  defp format_relays(relays) do
    rlist = Enum.map(relays, &(" #{&1}"))
            |> Enum.join("\n")
    "\nRelays (#{length(relays)})\n" <> rlist <> "\n"
  end

end

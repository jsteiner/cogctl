defmodule Cogctl.Actions.Permissions.Delete do
  use Cogctl.Action, "permissions delete"
  alias Cogctl.CogApi

  def option_spec do
    [{:permission, :undefined, :undefined, {:string, :undefined}, 'Permission name (required)'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_delete(client, :proplists.get_value(:permission, options))
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_delete(_client, :undefined) do
    display_arguments_error
  end

  defp do_delete(client, "site:" <> name) do
    case CogApi.permission_delete(client, name) do
      :ok ->
        display_output("Deleted site:#{name}")
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_delete(_client, _name) do
    {:error, "Only permissions under the site namespace can be deleted. e.g. site:deploy_blog"}
  end
end

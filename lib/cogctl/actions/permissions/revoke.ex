defmodule Cogctl.Actions.Permissions.Revoke do
  use Cogctl.Action, "permissions revoke"
  alias Cogctl.CogApi

  def option_spec do
    [{:permission, :undefined, :undefined, {:string, :undefined}, 'Permission name (required)'},
     {:user_to_revoke, :undefined, 'user', {:string, :undefined}, 'Username of user to revoke permission from'},
     {:group_to_revoke, :undefined, 'group', {:string, :undefined}, 'Name of group to revoke permission from'},
     {:role_to_revoke, :undefined, 'role', {:string, :undefined}, 'Role to revoke permission from'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        permission = :proplists.get_value(:permission, options)
        user_to_revoke = :proplists.get_value(:user_to_revoke, options)
        group_to_revoke = :proplists.get_value(:group_to_revoke, options)
        role_to_revoke = :proplists.get_value(:role_to_revoke, options)
        do_revoke(client, permission, user_to_revoke, group_to_revoke, role_to_revoke)
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_revoke(_client, :undefined, _user_to_revoke, _group_to_revoke, _role_to_revoke) do
    display_arguments_error
  end

  defp do_revoke(_client, _permission, :undefined, :undefined, :undefined) do
    display_arguments_error
  end

  defp do_revoke(client, permission, user_to_revoke, :undefined, :undefined) do
    case CogApi.permission_revoke(client, permission, "users", user_to_revoke) do
      {:ok, _resp} ->
        display_output("Revoked #{permission} from #{user_to_revoke}")
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_revoke(client, permission, :undefined, group_to_revoke, :undefined) do
    case CogApi.permission_revoke(client, permission, "groups", group_to_revoke) do
      {:ok, _resp} ->
        display_output("Revoked #{permission} from #{group_to_revoke}")
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_revoke(client, permission, :undefined, :undefined, role_to_revoke) do
    case CogApi.permission_revoke(client, permission, "roles", role_to_revoke) do
      {:ok, _resp} ->
        display_output("Revoked #{permission} from #{role_to_revoke}")
      {:error, error} ->
        display_error(error["error"])
    end
  end

  defp do_revoke(_client, _permission, _user_to_revoke, _group_to_revoke, _role_to_revoke) do
    display_arguments_error
  end
end

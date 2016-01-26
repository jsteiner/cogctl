defmodule Cogctl.Actions.ChatHandles.Create do
  use Cogctl.Action, "chat-handles create"
  alias Cogctl.CogApi
  alias Cogctl.Table

  # Whitelisted options passed as params to api client
  @params [:user, :chat_provider, :handle]

  def option_spec do
    [{:user, :undefined, 'user', {:string, :undefined}, 'Username of user to add handle to'},
     {:chat_provider, :undefined, 'chat-provider', {:string, :undefined}, 'Chat provider name'},
     {:handle, :undefined, 'handle', {:string, :undefined}, 'Handle'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_create(client, options)
      {:error, error} ->
        IO.puts "#{error["error"]}"
    end
  end

  defp do_create(client, options) do
    params = make_chat_handle_params(options)
    case CogApi.chat_handle_create(client, %{chat_handle: params}) do
      {:ok, resp} ->
        chat_handle = resp["chat_handle"]
        user = chat_handle["user"]["username"]
        chat_provider = chat_handle["chat_provider"]["name"]

        chat_handle = Map.merge(chat_handle, %{"user" => user, "chat_provider" => chat_provider})

        chat_handle_attrs = for {title, attr} <- [{"ID", "id"}, {"User", "user"}, {"Chat Provider", "chat_provider"}, {"Handle", "handle"}] do
          [title, chat_handle[attr]]
        end

        IO.puts("Created #{chat_handle["handle"]} for #{chat_provider} chat provider")
        IO.puts("")
        IO.puts(Table.format(chat_handle_attrs))

        :ok
      {:error, resp} ->
        {:error, resp}
    end
  end

  defp make_chat_handle_params(options) do
    options
    |> Keyword.take(@params)
    |> Enum.reject(&match?({_, :undefined}, &1))
    |> Enum.into(%{})
  end
end
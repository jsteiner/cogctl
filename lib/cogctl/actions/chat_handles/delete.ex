defmodule Cogctl.Actions.ChatHandles.Delete do
  use Cogctl.Action, "chat-handles delete"
  alias Cogctl.CogApi

  # Whitelisted options passed as params to api client
  @params [:user, :chat_provider]

  def option_spec do
    [{:user, :undefined, 'user', {:string, :undefined}, 'Username user that owns the handle to delete'},
     {:chat_provider, :undefined, 'chat-provider', {:string, :undefined}, 'Chat provider name'}]
  end

  def run(options, _args, _config, profile) do
    client = CogApi.new_client(profile)
    case CogApi.authenticate(client) do
      {:ok, client} ->
        do_delete(client, options)
      {:error, error} ->
        IO.puts "#{error["error"]}"
    end
  end

  defp do_delete(client, options) do
    params = make_chat_handle_params(options)
    case CogApi.chat_handle_delete(client, %{chat_handle: params}) do
      :ok ->
        IO.puts("Deleted chat handle owned by #{params[:user]} for #{params[:chat_provider]} chat provider")
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
defmodule Cogctl.CogApi do

  defstruct [proto: "http", host: nil, port: nil, version: 1, token: nil, username: nil,
             password: nil]

  def new_client(profile=%Cogctl.Profile{}) do
    proto = if profile.secure == true do
      "https"
    else
      "http"
    end
    %__MODULE__{proto: proto, host: profile.host, port: profile.port, username: profile.user,
                password: profile.password}
  end

  def authenticate(%__MODULE__{token: nil}=api) do
    response = HTTPotion.post(make_url(api, "token", [username: api.username,
                                                      password: api.password]),
                              headers: make_headers(api, ["Accept": "application/json"]))
    body = Poison.decode!(response.body)
    case HTTPotion.Response.success?(response) do
      true ->
        token = get_in(body, ["token", "value"])
        {:ok, %{api | token: token}}
      false ->
        {:error, body}
    end
  end
  def authenticate(%__MODULE__{}=api) do
    {:ok, api}
  end

  def is_bootstrapped?(%__MODULE__{}=api) do
    response = HTTPotion.get(make_url(api, "bootstrap"), headers: make_headers(api))
    api_result(response)
  end

  def bootstrap(%__MODULE__{}=api) do
    response = HTTPotion.post(make_url(api, "bootstrap"))
    api_result(response)
  end

  def list_all_bundles(%__MODULE__{}=api) do
    response = HTTPotion.get(make_url(api, "bundles"),
                             headers: make_headers(api))
    api_result(response)
  end

  def bundle_info(%__MODULE__{}=api, bundle_id) do
    response = HTTPotion.get(make_url(api, "bundles/" <> URI.encode(bundle_id)),
                             headers: make_headers(api))
    api_result(response)
  end

  def relays_for_bundle(%__MODULE__{}=api, bundle_id) do
    response = HTTPotion.get(make_url(api, "bundles/" <> URI.encode(bundle_id) <> "/relays"),
                                      headers: make_headers(api))
    api_result(response)
  end

  def bundle_delete(%__MODULE__{}=api, bundle_id) do
    response = HTTPotion.delete(make_url(api, fn -> "bundles/" <> URI.encode(bundle_id) end),
                                headers: make_headers(api))
    api_result(response)
  end

  defp make_url(%__MODULE__{proto: proto, host: host, port: port,
                            version: version}, route, params \\ []) do
    route = if is_function(route) do
      route.()
    else
      route
    end
    url = "#{proto}://#{host}:#{port}/v#{version}"
    url = if String.starts_with?(route, "/") do
      "#{url}#{route}"
    else
      "#{url}/#{route}"
    end
    if length(params) == 0 do
      url
    else
      URI.encode(url <> "?" <> URI.encode_query(params))
    end
  end

  defp make_headers(api, others \\ [])

  defp make_headers(%__MODULE__{token: nil}, others) do
    others
  end
  defp make_headers(%__MODULE__{token: token}, others) do
    ["authorization": "token " <> token] ++ others
  end

  defp response_type(response) do
    if HTTPotion.Response.success?(response) do
      :ok
    else
      :error
    end
  end

  defp api_result(response) do
    if response.status_code in [401, 403] do
      {:error, %{"error" => "Authentication error"}}
    else
      response_type = response_type(response)
      if response.body == nil or response.body == "" do
        response_type
      else
        {response_type, Poison.decode!(response.body)}
      end
    end
  end

end

defmodule SmsBlitz.Adapters.Plivo do
  @behaviour SmsBlitz.Adapter
  @base_uri "https://api.plivo.com/v1"

  def authenticate({user_id, user_token}) do
    %{
      uri:  Enum.join([@base_uri, "Account", user_id, "Message"], "/") <> "/",
      auth: Base.encode64("#{user_id}:#{user_token}")
    }
  end

  def send_sms(%{uri: uri, auth: auth}, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do

    body = %{
      src: from,
      dst: to,
      text: message,
      type: "sms",
      log: true
    } |> Poison.encode!

    {:ok, %{body: resp, status_code: status_code}} = HTTPoison.post(
      uri,
      body,
      [
        {"Authorization", "Basic " <> auth},
        {"Content-Type", "application/json"}
      ]
    )

    {:ok, %{"api_id" => api_id, "message" => message}} = Poison.decode(resp)

    %{
      id: api_id,
      result_string: message,
      status_code: status_code
    }
  end

end

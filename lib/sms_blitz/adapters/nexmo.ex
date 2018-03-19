defmodule SmsBlitz.Adapters.Nexmo do
  @behaviour SmsBlitz.Adapter
  @base_uri "https://rest.nexmo.com/sms/json"

  defmodule Config do
    defstruct [:uri, :api_key, :api_secret]
    @type t :: %__MODULE__{}
  end

  @spec authenticate({binary()}) :: Config.t
  def authenticate({key, secret}) do
    %Config{
      uri: @base_uri,
      api_key: key,
      api_secret: secret
    }
  end

  @spec send_sms(Config.t, SmsBlitz.Adapter.sms_params()) :: SmsBlitz.Adapter.sms_result()
  def send_sms(
        %Config{}=conf,
        from: from,
        to: to,
        message: message
      )
      when is_binary(from) and is_binary(to) and is_binary(message) do
    body =
      %{
        from: from,
        to: to,
        text: message,
        api_key: conf.api_key,
        api_secret: conf.api_secret,
      }
      |> Poison.encode!()

    HTTPoison.post(conf.uri, body, [{"Content-Type", "application/json"}])
    |> handle_response!
  end

  def handle_response!({:ok, %{headers: headers, body: resp, status_code: 200}}) do
    handle_messages(headers, Poison.decode!(resp))
  end

  def handle_messages(headers, %{"messages" => [response_status]}) do
    if response_status["status"] == "0" do
      %{
        id: response_status["message-id"],
        result_string: "success",
        status_code: response_status["status"]
      }
    else
      {_key, trace_id} =
        Enum.find(headers, fn
          {"X-Nexmo-Trace-Id", _} -> true
          _ -> false
        end)

      %{
        id: trace_id,
        result_string: response_status["error-text"],
        status_code: response_status["status"]
      }
    end
  end
end

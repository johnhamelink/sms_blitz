defmodule SmsBlitz.Adapters.Twilio do
  @behaviour SmsBlitz.Adapter
  @base_uri "https://api.twilio.com/2010-04-01/Accounts"

  defmodule Config do
    defstruct [:uri, :account_sid, :token]
    @type t :: %__MODULE__{}
  end

  @spec authenticate({binary()}) :: Config.t
  def authenticate({account_sid, token}) do
    %Config{
      uri: Enum.join([@base_uri, account_sid, "Messages.json"], "/"),
      account_sid: account_sid,
      token: token
    }
  end

  @spec send_sms(Config.t, SmsBlitz.Adapter.sms_params) :: SmsBlitz.Adapter.sms_result
  def send_sms(%Config{}=auth, from: from, to: to, message: message)
      when is_binary(from) and is_binary(to) and is_binary(message) do
    params = [
      To: to,
      From: from,
      Body: message
    ]

    HTTPoison.post!(auth.uri, {:form, params}, %{}, [hackney: [basic_auth: {auth.account_sid, auth.token}]])
    |> handle_response
  end

  defp handle_response(%HTTPoison.Response{body: resp, status_code: status_code}) do
    resp_json = Poison.decode!(resp)
    %{
      id: resp_json["sid"],
      result_string: resp_json["error_message"] || resp_json["body"],
      status_code: status_code
    }
  end
end

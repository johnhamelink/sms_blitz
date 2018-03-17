defmodule SmsBlitz.Adapters.Twilio do
  @behaviour SmsBlitz.Adapter
  @base_uri "https://api.twilio.com/2010-04-01/Accounts"

  def authenticate({account_sid}) do
    %{
      uri: Enum.join([@base_uri, account_sid, "Messages.json"], "/")
    }
  end

  def send_sms(%{uri: uri}, from: from, to: to, message: message)
      when is_binary(from) and is_binary(to) and is_binary(message) do
    params = [
      To: to,
      From: from
    ]

    handle_response!(HTTPoison.post(uri, {:form, params}))
  end

  defp handle_response!({:ok, %HTTPoison.Response{body: resp, status_code: status_code}}) do
    resp_json = Poison.decode!(resp)
    %{
      id: resp_json["sid"],
      result_string: resp_json["error_message"] || resp_json["body"],
      status_code: status_code
    }
  end
end

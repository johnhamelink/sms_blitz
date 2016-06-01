defmodule SmsBlitz.Adapters.Twilio do
  @base_uri "https://api.twilio.com/2010-04-01/Accounts"

  def authenticate({accoutsid}) do
    %{
      uri: Enum.join([@base_uri, accoutsid, "Messages.json"], "/")
    }
  end

  def send_sms(%{uri: uri}, from: from, to: to, message: message) when is_binary(from) and is_binary(to) and is_binary(message) do
    params = [
      To: to,
      From: from
    ]
    {:ok, %HTTPoison.Response{body: resp, status_code: status_code}} = HTTPoison.post(
      uri,
      {:form, params}
    )
    {:ok, resp_json} = Poison.decode(resp)

    %{
      id: resp_json["sid"],
      message: resp_json["error_message"] || resp_json["message"],
      status_code: status_code
    }
  end
end

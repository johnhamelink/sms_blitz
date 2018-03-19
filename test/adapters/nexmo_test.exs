defmodule SmsBlitz.Adapters.NexmoTest do
  use ExUnit.Case
  alias SmsBlitz.Adapters.Nexmo
  import Mock
  @config {"key", "secret"}

  test "#authenticate" do
    expected = %{
      auth: %{
        key: "key",
        secret: "secret"
      },
      uri: "https://rest.nexmo.com/sms/json"
    }

    assert Nexmo.authenticate(@config) == expected
  end

  describe "#send_sms" do
    test "successful sending" do
      response = %{
        "message-count": 1,
        messages: [
          %{
            to: "447700900000",
            "message-id": "0A0000000123ABCD1",
            status: "0",
            "remaining-balance": "3.14159265",
            "message-price": "0.03330000",
            network: "12345"
          }
        ]
      }

      auth = Nexmo.authenticate(@config)

      with_mock HTTPoison, post: fn _, _, _ -> {:ok, make_response(response)} end do
        result =
          Nexmo.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == %{id: "0A0000000123ABCD1", result_string: "success", status_code: "0"}

        assert called(
                 HTTPoison.post("https://rest.nexmo.com/sms/json", :_, [
                   {"Content-Type", "application/json"}
                 ])
               )
      end
    end

    test "failing to send an sms" do
      response = %{
        "message-count": 1,
        messages: [
          %{
            status: "2",
            "error-text": "Missing to param"
          }
        ]
      }

      auth = Nexmo.authenticate(@config)

      with_mock HTTPoison, post: fn _, _, _ -> {:ok, make_response(response)} end do
        result =
          Nexmo.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == %{id: "testing", result_string: "Missing to param", status_code: "2"}

        assert called(
                 HTTPoison.post("https://rest.nexmo.com/sms/json", :_, [
                   {"Content-Type", "application/json"}
                 ])
               )
      end
    end
  end

  def make_response(response) do
    headers = [{"X-Nexmo-Trace-Id", "testing"}]

    %HTTPoison.Response{
      status_code: 200,
      body: Poison.encode!(response),
      headers: headers
    }
  end
end

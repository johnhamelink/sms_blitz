defmodule SmsBlitz.Adapters.TwilioTest do
  use ExUnit.Case
  alias SmsBlitz.Adapters.Twilio
  import Mock
  @auth_sid "ACd2bd41c5a2524f439f82eea7c5ea5c80"

  describe "#authenticate" do
    test "authentication with account_sid" do
      expected = %{
        uri: "https://api.twilio.com/2010-04-01/Accounts/#{@auth_sid}/Messages.json"
      }

      assert Twilio.authenticate({@auth_sid}) == expected
    end
  end

  describe "#send_sms" do
    test "sending an sms successfullly" do
      auth = Twilio.authenticate({@auth_sid})
      sid = "MMabdfcc43604446058f6608b1633cd52f"

      response = %{
        "error_message" => nil,
        "sid" => sid,
        "body" => "testing"
      }

      fake_response = %HTTPoison.Response{status_code: 200, body: Poison.encode!(response)}

      with_mock HTTPoison, post: fn _, _ -> {:ok, fake_response} end do
        result =
          Twilio.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == %{id: sid, result_string: "testing", status_code: 200}
      end
    end

    test "sending an sms and receiving an error" do
      auth = Twilio.authenticate({@auth_sid})
      sid = "MMabdfcc43604446058f6608b1633cd52f"

      response = %{
        "error_message" => "testing error",
        "sid" => sid
      }

      fake_response = %HTTPoison.Response{status_code: 500, body: Poison.encode!(response)}

      with_mock HTTPoison, post: fn _, _ -> {:ok, fake_response} end do
        result =
          Twilio.send_sms(auth, from: "+4412345678910", to: "+4423456789101", message: "Testing")

        assert result == %{id: sid, result_string: "testing error", status_code: 500}
      end
    end
  end
end

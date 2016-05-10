defmodule Pagexduty.Server do
  use GenServer

  def start_link(service_key) do
    GenServer.start_link(__MODULE__, service_key, name: __MODULE__)
  end

  def trigger(description) do
    incident = %{description: description}
    GenServer.call __MODULE__, {:trigger, incident}
  end

  def trigger(description, details) when is_map(details) do
    incident = %{description: description, details: details}
    GenServer.call __MODULE__, {:trigger, incident}
  end

  def trigger(description, incident_key) when is_binary(incident_key) do
    incident = %{description: description, incident_key: incident_key}
    GenServer.call __MODULE__, {:trigger, incident}
  end

  def trigger(description, incident_key, details) do
    incident = %{description: description, incident_key: incident_key, details: details}
    GenServer.call __MODULE__, {:trigger, incident}
  end

  def resolve(description) do
    incident = %{description: description}
    GenServer.call __MODULE__, {:resolve, incident}
  end

  def resolve(description, details) when is_map(details) do
    incident = %{description: description, details: details}
    GenServer.call __MODULE__, {:resolve, incident}
  end

  def resolve(description, incident_key) when is_binary(incident_key) do
    incident = %{description: description, incident_key: incident_key}
    GenServer.call __MODULE__, {:resolve, incident}
  end

  def resolve(description, incident_key, details) do
    incident = %{description: description, incident_key: incident_key, details: details}
    GenServer.call __MODULE__, {:resolve, incident}
  end

  def handle_call({event_type, incident}, _from, service_key) do
    response = create_event(incident, service_key, event_type)
    {:reply, response, service_key}
  end

  def create_event(event_params, service_key, event_type) do
    params = Map.merge(event_params, %{"service_key" => service_key, "event_type" => event_type})
    json = json_encode(params)
    response = post(create_event_url, json, default_headers)
    json_decode(response.body)
  end

  defp post(url, body, headers) do
    HTTPoison.post!(url, body, headers)
  end

  defp create_event_url do
    "https://events.pagerduty.com/generic/2010-04-15/create_event.json"
  end

  defp default_headers do
    %{"Content-type" => "application/json"}
  end

  defp json_decode(body) do
    JSX.decode!(body)
  end

  defp json_encode(params) do
    JSX.encode!(params)
  end
end

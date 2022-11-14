defmodule TelegramService.Events.Subscriptions do
  @moduledoc "Context for event subscriptions"

  use TelegramService.External.CeloConsts
  alias TelegramService.Events.SubscriberCache, as: Cache

  def subscribe(chat_id), do: subscribe(chat_id, @cusd_proxy_address, @transfer_topic)
  def subscribe(chat_id, contract_address, topic) do
    Cache.add_subscription(chat_id, contract_address, topic)
  end

  def subscribe_governance(chat_id), do: subscribe(chat_id, @governance_proxy_address, @proposal_queued_topic)
  def unsubscribe_governance(chat_id), do: unsubscribe(chat_id, @governance_proxy_address, @proposal_queued_topic)

  def unsubscribe(chat_id), do: unsubscribe(chat_id, @cusd_proxy_address, @transfer_topic)
  def unsubscribe(chat_id, contract_address, topic) do
    Cache.remove_subscription(chat_id, contract_address, topic)
  end

  def get_subscribers(%{"contract_address_hash" => contract, "topic" => topic}) do
    get_subscribers(contract, topic)
  end

  def get_subscribers(contract_address, topic) do
    Cache.get_subscribers(contract_address, topic)
  end
end
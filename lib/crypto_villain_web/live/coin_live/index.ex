defmodule CryptoVillainWeb.CoinLive.Index do
  use CryptoVillainWeb, :live_view

  import CryptoVillain.{CoinsManager, CoinsClient}
  alias CryptoVillain.{CoinInfo, Accounts, Accounts.User, Threshold}

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      subscribe()
      Threshold.subscribe()
    end

    {:ok,
     session
     |> assign_defaults(socket)
     |> set_user_client()
     |> assign_widget_defaults()}
  end

  @impl true
  def handle_event("show_change", _show, socket) do
    {:noreply, assign(socket, :show, !socket.assigns.show)}
  end

  @impl true
  def handle_event("clear_threshold", %{"coin" => coin}, socket) do
    with updated_user <- Accounts.clear_coin_threshold(socket.assigns.current_user, coin) do
      {:noreply, socket |> assign_user_with_thresholds(updated_user)}
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{"threshold" => params},
        %{assigns: %{threshold: threshold}} = socket
      ) do
    changeset =
      threshold
      |> CoinInfo.change_threshold(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:threshold, threshold_struct(params))}
  end

  @impl true
  def handle_event("threshold_save", %{"threshold" => threshold}, socket) do
    with threshold <- convert_price(AtomicMap.convert(threshold)),
         updated_user <- Accounts.set_coin_threshold(socket.assigns.current_user, threshold) do
      socket =
        socket
        |> assign(:threshold, %Threshold{})
        |> assign_user_with_thresholds(updated_user)

      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_threshold", _show, socket) do
    {:noreply, assign(socket, :show_threshold, !socket.assigns.show_threshold)}
  end

  @impl true
  def handle_event("search", %{"query" => params}, socket) do
    {:noreply,
     socket
     |> assign(:search, params["query"])
     |> assign(:search_coins, search_action_apply(socket, params["query"]))}
  end

  @impl true
  def handle_event("favorite_coin", params, socket) do
    {user_id, coin} = {params["user"], %CoinInfo{name: params["coin"]}}

    with user <- Accounts.get_user!(user_id),
         updated_user <- Accounts.set_user_favorite_coins(user, coin),
         search_coins <- coins_update_flow(socket.assigns, updated_user) do
      {:noreply,
       socket
       |> assign(:search_coins, search_coins)
       |> assign_user_with_thresholds(updated_user)}
    end
  end

  @impl true
  def handle_info({CryptoVillain.CoinsManager, {:coins, _action}, _coin}, socket) do
    {:noreply, socket |> assign(search_coins: search_action_apply(socket, socket.assigns.search))}
  end

  @impl true
  def handle_info({CryptoVillain.Threshold, {:thresholds, _action}, updated_user}, socket) do
    {:noreply, socket |> assign_user_with_thresholds(updated_user)}
  end

  defp search_action_apply(socket, query) do
    socket.assigns
    |> query_by_user_exist(query)
    |> filter_coins()
    |> mark_is_favorite(socket.assigns.current_user)
  end

  defp query_by_user_exist(assigns, query) do
    if assigns.current_user && is_query_blank?(query),
      do: get_coins_names(assigns.current_user.favorite_coins),
      else: query
  end

  defp coins_update_flow(assigns, updated_user) do
    if is_nil(assigns.search) do
      updated_user.favorite_coins
      |> filter_favorite_coins(updated_user)
    else
      assigns.search_coins
      |> mark_is_favorite(updated_user)
    end
  end

  defp filter_favorite_coins(coins, user) do
    coins
    |> get_coins_names()
    |> filter_coins()
    |> mark_is_favorite(user)
  end

  defp filter_coins(query) when is_binary(query) do
    Enum.filter(get_state(), fn item ->
      item.name =~ ~r/#{query}/
    end)
  end

  defp filter_coins(query) when is_list(query) do
    Enum.filter(get_state(), fn item ->
      item.name in query
    end)
  end

  defp filter_coins(_query), do: get_state()

  defp assign_widget_defaults(socket) do
    socket
    |> assign(:show, false)
    |> assign(:show_threshold, false)
    |> assign(:threshold, %Threshold{})
    |> assign_changeset()
    |> assign_thresholds()
    |> assign(:search, nil)
    |> assign(:search_coins, search_action_apply(socket, ""))
  end

  defp assign_changeset(%{assigns: %{threshold: threshold}} = socket) do
    socket |> assign(:changeset, CoinInfo.change_threshold(threshold))
  end

  defp assign_thresholds(socket) do
    socket |> assign(:coins_threshold, get_coins_threshold(socket.assigns.current_user))
  end

  defp assign_user_with_thresholds(socket, updated_user) do
    socket
    |> assign(:current_user, updated_user)
    |> assign_thresholds()
  end

  defp mark_is_favorite(coins, %User{} = user) do
    Enum.map(coins, &coin_in_favorites(&1, user.favorite_coins))
  end

  defp mark_is_favorite(coins, _), do: coins

  defp coin_in_favorites(coin, favorite_coins) do
    Map.put(coin, :is_favorite, coin.name in get_coins_names(favorite_coins))
  end

  defp get_coins_names(coins) do
    Enum.map(coins, &Map.get(&1, :name))
  end

  defp set_user_client(socket) do
    unless Map.has_key?(socket.assigns, :user_client_code) do
      user_code =
        ?a..?z
        |> Enum.take_random(12)
        |> List.to_string()

      with {:ok, _pid} <- run_listener(user_code) do
        socket = socket |> assign(:user_client_code, user_code)
      end
    end

    socket
  end

  defp is_query_blank?(query) do
    is_blank?(query) or is_nil(query)
  end

  defp threshold_struct(map) do
    struct(
      Threshold,
      map
      |> AtomicMap.convert()
      |> convert_price()
    )
  end

  defp get_coins_threshold(user) do
    filter_coins_threshold(user)
    |> Enum.map(fn coin -> coin.threshold end)
    |> coins_to_threshold()
  end

  defp coins_to_threshold(coins) do
    Enum.map(coins, fn coin -> threshold_struct(coin) end)
  end

  defp filter_coins_threshold(user) when is_nil(user), do: []

  defp filter_coins_threshold(user) do
    Enum.filter(user.favorite_coins, fn coin -> coin.threshold != %{} end)
  end

  defp convert_price(%{price: price} = data) when is_binary(price) do
    price = if is_blank?(price), do: nil, else: elem(Float.parse(price), 0)
    %{data | price: price}
  end

  defp convert_price(%{price: price} = data) when is_integer(price), do: %{data | price: price / 1}

  defp convert_price(%{price: price} = data) when is_float(price), do: %{data | price: price}
end

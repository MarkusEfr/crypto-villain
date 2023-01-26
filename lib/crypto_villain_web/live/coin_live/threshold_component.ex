defmodule CryptoVillainWeb.CoinLive.ThresholdComponent do
  use CryptoVillainWeb, :live_component

  defp get_coins_names(coins) do
    Enum.map(coins, &Map.get(&1, :name))
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@current_user}>
          <div class="d-grid gap-2">
            <button class="btn btn-dark" type="button" data-bs-toggle="collapse" data-bs-target="#threshold-box" aria-expanded="false" aria-controls="threshold-box" phx-click="show_threshold">
              Threshold
            </button>
          </div>
          <div class={"collapse #{if @show_threshold do "show" end}"} id="threshold-box">
              <div class="card card-body">
                  <.form :let={f} for={@changeset} id="threshold-form" phx-change="validate" phx-submit="threshold_save" phx-target={"#coin-live"}>
                      <div class="input-group mb-3">
                          <%= select f, :coin, get_coins_names(@current_user.favorite_coins), value: @threshold.coin, class: "form-control", "phx-debounce": "800"%>
                        <span class="input-group-text">
                            <%= Bootstrap.Icons.coin()%>
                        </span>
                        </div>
                        <div class="input-group mb-3">
                            <%= select f, :operation, [">=": ">=", "<=": "<="], value: @threshold.operation, class: "form-control", "phx-debounce": "800" %>
                            <%= number_input f, :price, value: @threshold.price, class: "form-control", "phx-debounce": "300", placeholder: "expected price", step: ".000001", required: true %>
                            <%= error_tag f, :price %>
                            <%= submit "Save", phx_disable_with: "Saving...", class: "btn btn-secondary #{if !@changeset.valid?, do: "disabled"}"  %>
                        </div>
                    </.form>

                    <table :if={!Enum.empty?(@coins_threshold)} class="table table-borderless">
                        <hr>
                        <tbody>
                          <tr :for={threshold <- @coins_threshold}>
                            <td><%= threshold.coin %></td>
                            <td><%= threshold.operation %></td>
                            <td><%= Decimal.from_float(threshold.price) %></td>
                            <td>
                                <span class="threshold-action px-2 pb-1 col-1" phx-click="clear_threshold" phx-target={"#coin-live"} phx-value-coin={threshold.coin}>
                                    <%= Bootstrap.Icons.x_circle()%>
                                </span>
                            </td>
                          </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    """
  end
end

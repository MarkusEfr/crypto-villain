defmodule CryptoVillainWeb.ModalComponent do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  slot(:header)
  slot(:inner_block, required: true)

  attr :footer_text, :string, required: false
  attr :return_to, :atom

  def render(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch Bootstrap.Icons.x_octagon(),
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>
        <div class="modal-header">
          <%= render_slot(@header) %>
        </div>
        <div class="modal-body">
          <%= render_slot(@inner_block) %>
        </div>
        <div class="modal-footer">
          <a class="text-muted">
          <%= @footer_text %>
          </a>
        </div>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end

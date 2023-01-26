defmodule CryptoVillainWeb.UserSettingsController do
  use CryptoVillainWeb, :controller

  alias ElixirSense.Plugins.Ecto
  alias CryptoVillain.{Accounts, Avatar}
  alias CryptoVillainWeb.UserAuth

  plug :assign_email_and_password_changesets
  plug :assign_avatar_changeset

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  def update(conn, %{"action" => "update_avatar", "user" => %{"avatar" => avatar}} = params) do
    user = conn.assigns.current_user
    with {:ok, file} <- Avatar.store({avatar, user}),
         {:ok, updated_user} <- Accounts.update_user_avatar(user, %{avatar: avatar}) do
      conn
      |> put_flash(:info, "Password updated successfully.")
      |> redirect(to: Routes.user_settings_path(conn, :edit))
    else
      :error ->
        conn
        |> put_flash(:error, "Error occurred during avatar set operation!")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end

  defp assign_avatar_changeset(conn, _opts) do
    conn |> assign(:avatar_changeset, Accounts.change_user_avatar(conn.assigns.current_user, %{}))
  end
end

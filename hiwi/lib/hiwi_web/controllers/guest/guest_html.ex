defmodule HiwiWeb.Guest.GuestHTML do
    @moduledoc """
    This module contains pages rendered by GuestController.

    See the `guest_html` directory for all templates available.
    """
    use HiwiWeb, :html

    embed_templates "guest_html/*"
end

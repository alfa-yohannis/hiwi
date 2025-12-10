defmodule HiwiWeb.Home.HomeHTML do
    @moduledoc """
    This module contains pages rendered by GuestController.

    See the `home_html` directory for all templates available.
    """
    use HiwiWeb, :html

    embed_templates "home_html/*"
end

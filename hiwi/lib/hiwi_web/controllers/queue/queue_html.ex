defmodule HiwiWeb.Queue.QueueHTML do
    @moduledoc """
    This module contains pages rendered by GuestController.

    See the `queue_html` directory for all templates available.
    """
    use HiwiWeb, :html

    embed_templates "queue_html/*"
end

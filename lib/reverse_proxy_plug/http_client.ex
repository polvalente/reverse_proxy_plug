defmodule ReverseProxyPlug.HTTPClient do
  @moduledoc """
  Behaviour defining the HTTP client interface needed for reverse proxying.
  """
  @type error :: __MODULE__.Error.t()
  @type response_mode :: :stream | :buffer

  @doc """
  Makes an HTTP request which can be either synchronous or chunked.

  ## Chunked vs Buffered Requests

  The `:response_mode` option given in the `ReverseProxyPlug.HTTPClient.Request`
  struct's `:options` field can be either `:stream` or `:buffer`.

  If `:response_mode` is `:stream`, the following messages will be expected by the
  process referenced in the `:stream_to` option:

    * `%ReverseProxyPlug.HTTPClient.AsyncStatus{}`:

      Carries the response status code

    * `%ReverseProxyPlug.HTTPClient.AsyncHeaders{}`:

      Carries the response headers

    * `%ReverseProxyPlug.HTTPClient.AsyncChunk{}`:

      Carries a given chunk for the response, which will be immediately
      streamed to the client

    * `%ReverseProxyPlug.HTTPClient.AsyncEnd{}`:

      Determines the end of the stream.

  Keep in mind that the response is ignored for `:stream` responses,
  so any errors will result in a timeout from the receive loop.

  If `:response_mode` is `:buffer`, the function's result will be treated as
  if it contains the complete response for the client.
  """
  @callback request(request :: __MODULE__.Request.t()) ::
              {:ok,
               __MODULE__.Response.t()
               | __MODULE__.AsyncChunk.t()
               | __MODULE__.AsyncEnd.t()
               | __MODULE__.AsyncHeaders.t()
               | __MODULE__.AsyncResponse.t()
               | __MODULE__.AsyncStatus.t()
               | __MODULE__.MaybeRedirect.t()}
              | {:error, error()}

  @doc "Defines supported `:response_mode` values"
  @callback supported_response_modes() :: [response_mode()]

  @optional_callbacks [supported_response_modes: 0]
end

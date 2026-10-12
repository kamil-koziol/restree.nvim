# restree.nvim

Run [restree](https://github.com/kamil-koziol/restree) `.http` request files straight from Neovim and view the response in a split.

## Requirements

- Neovim 0.10+ (uses `vim.system`)
- [`restree`](https://github.com/kamil-koziol/restree) in your `$PATH`
- [`jq`](https://jqlang.github.io/jq/) (optional, for pretty-printed JSON)

## Installation

### vim.pack (Neovim 0.12+)

```lua
vim.pack.add({ "https://github.com/kamil-koziol/restree.nvim" })
```

### lazy.nvim

```lua
{
  "kamil-koziol/restree.nvim",
  ft = "http",
}
```

## Usage

Open a `.http` file and run:

| Command                  | What it does                          |
| ------------------------ | ------------------------------------- |
| `:Restree`               | Run the file, show the response body  |
| `:Restree jq`            | Pipe the response through `jq`        |
| `:Restree headers`       | Show response headers above the body  |
| `:Restree jq headers`    | Both                                  |

The result opens in a vertical split. Press `q` to close it.

### Default keymaps

Set only in buffers with filetype `http`:

| Key          | Command                |
| ------------ | ---------------------- |
| `<leader>rr` | `:Restree`             |
| `<leader>rj` | `:Restree jq`          |
| `<leader>ra` | `:Restree jq headers`  |

## Example

`example.http`:

```http
GET https://httpbin.org/get
Accept: application/json
```

Open it and press `<leader>rj` to see the formatted JSON response.

## Troubleshooting

- **Keymaps don't work:** make sure the buffer's filetype is `http` (`:set ft?`). If not, add this to your config:

  ```lua
  vim.filetype.add({ extension = { http = "http" } })
  ```
- **Empty or error output:** run `restree run -k -v yourfile.http` in a terminal to see what restree reports.

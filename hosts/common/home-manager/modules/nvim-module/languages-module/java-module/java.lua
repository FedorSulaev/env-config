local home = os.getenv("HOME")
local jdtls = require("jdtls")
local root_dir = require("jdtls.setup").find_root({ "packageInfo" }, "Config")
local eclipse_workspace = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local ws_folders_jdtls = {}
if root_dir then
    local file = io.open(root_dir .. "/.bemol/ws_root_folders")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_jdtls, "file://" .. line)
        end
        file:close()
    end
end

-- Helper function for creating keymaps
local function nnoremap(rhs, lhs, bufopts, desc)
    bufopts.desc = desc
    vim.keymap.set("n", rhs, lhs, bufopts)
end

local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    client.server_capabilities.semanticTokensProvider = nil

    nnoremap("gD", vim.lsp.buf.declaration, bufopts, "Go to declaration")
    --nnoremap("gd", builtin.lsp_definitions, bufopts, "Go to definition")-- Telescope
    --nnoremap("gi", builtin.lsp_implementations, bufopts, "Go to implementation")-- Telescope
    nnoremap("<C-k>", vim.lsp.buf.signature_help, bufopts, "Show signature")
    nnoremap("<space>wa", vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
    nnoremap("<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
    nnoremap("<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts, "List workspace folders")
    --nnoremap("<space>D", builtin.lsp_type_definitions, bufopts, "Go to type definition")-- Telescope
    nnoremap("<space>rn", vim.lsp.buf.rename, bufopts, "Rename")
    nnoremap("<space>ca", vim.lsp.buf.code_action, bufopts, "Code actions")
    vim.keymap.set(
        "v",
        "<space>ca",
        "<ESC><CMD>lua vim.lsp.buf.range_code_action()<CR>",
        { noremap = true, silent = true, buffer = bufnr, desc = "Code actions" }
    )
    -- nnoremap('<space>f', function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")

    -- Java extensions provided by jdtls
    nnoremap("<space>di", jdtls.organize_imports, bufopts, "Organize imports")
    nnoremap("<space>ev", jdtls.extract_variable, bufopts, "Extract variable")
    nnoremap("<space>ec", jdtls.extract_constant, bufopts, "Extract constant")
    nnoremap("<space>lf", function()
        vim.diagnostic.open_float({ border = "rounded" })
    end, bufopts, "Floating diagnostic")
    vim.keymap.set(
        "v",
        "<space>em",
        [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
        { noremap = true, silent = true, buffer = bufnr, desc = "Extract method" }
    )
end

local config = {
    flags = {
        debounce_text_changes = 80,
    },
    on_attach = on_attach,
    root_dir = root_dir,
    init_options = {
        workspaceFolders = ws_folders_jdtls,
        bundles = {
            vim.fn.glob(home .. "/.java-debug/java-debug.jar", 1),
            vim.fn.glob(home .. "/.java-test/java-test.jar", 1),
        },
    },
    settings = {
        java = {
            format = {
                settings = { url = vim.fn.glob(home .. ".config/nvim/after/ftplugin/eclipse-java-google-style.xml", 1) },
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
                filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                },
                favoriteStaticMembers = {
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                    "org.mockito.ArgumentMatchers.*",
                },
            },
            sources = {
                organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                },
            },
        },
    },
    cmd = {
        "jdtls",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx8g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "--jvm-arg=-javaagent:" .. home .. "/.lombok/lombok.jar",
        "-data",
        eclipse_workspace,
    },
}

jdtls.start_or_attach(config)

vim.keymap.set("n", "<space>co", "<CMD>lua require('jdtls').organize_imports()<CR>", { desc = "Organize Imports" })
vim.keymap.set("n", "<space>crv", "<CMD>lua require('jdtls').extract_variable()<CR>", { desc = "Extract Variable" })
vim.keymap.set(
    "v",
    "<space>crv",
    "<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>",
    { desc = "Extract Variable" }
)
vim.keymap.set("n", "<space>crc", "<CMD>lua require('jdtls').extract_constant()<CR>", { desc = "Extract Constant" })
vim.keymap.set(
    "v",
    "<space>crc",
    "<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>",
    { desc = "Extract Constant" }
)
vim.keymap.set(
    "v",
    "<space>crm",
    "<ESC><CMD>lua require('jdtls').extract_method(true)<CR>",
    { desc = "Extract Method" }
)

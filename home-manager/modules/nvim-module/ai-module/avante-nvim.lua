require("avante_lib").load()
require("avante").setup({
    provider = "bedrock",
    bedrock = {
        model = "anthropic.claude-sonnet-4-20250514-v1:0",
        max_tokens = 6553,
        aws_profile = "cline-profile",
        aws_region = "eu-west-3",
    },
})

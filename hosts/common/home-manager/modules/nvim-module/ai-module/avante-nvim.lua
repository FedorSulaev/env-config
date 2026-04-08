require("avante_lib").load()
require("avante").setup({
    provider = "bedrock",
    providers = {
    	bedrock = {
        	model = "anthropic.claude-sonnet-4-20250514-v1:0",
        	aws_profile = "cline-profile",
        	aws_region = "eu-west-3",
		extra_request_body = {
			max_tokens = 6553,
		},
    	},
    }
})

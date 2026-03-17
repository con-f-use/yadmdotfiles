# Written by Tobi
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.roles.claude;
in
{
  options.roles.claude = {
    enable = lib.mkEnableOption "Activate claude code";
    auth-token-file = lib.mkOption {
      type = lib.types.str;
      description = "The path to the claude auth token";
      default = "/etc/secrets/claude";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.claude-code ];

    environment.etc."claude-code/managed-settings.json".text = ''
      {
        "$schema": "https://json.schemastore.org/claude-code-settings.json",
        "apiKeyHelper": "cat ${cfg.auth-token-file}",
        "env": {
          "ANTHROPIC_BASE_URL": "https://api.iq.cudasvc.com",
          "CLAUDE_CODE_SUBAGENT_MODEL": "claude-sonnet-4-5",
          "ANTHROPIC_MODEL": "claude-opus-4-5",
          "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-5",
          "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-5",
          "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5",
          "DISABLE_PROMPT_CACHING": "0",
          "DISABLE_TELEMETRY": "1",
          "DISABLE_ERROR_REPORTING": "1",
          "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
          "CLAUDE_CONFIG_DIR": "~/.config/claude"
        },
        "model": "opus"
      }
    '';

    allowUnfreePackages = [ "claude-code" ];
  };
}

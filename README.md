# sourcemod-plugins

## botcon - Bot Connection Handler

Handle bot presence on empty servers. Rationale: Games usually remove bots once all human players have left. The presence of SourceTV disrupts this behaviour on some games and the bots stay connected and continue to play.

`sm_botcon_enable` Enable/Disable the plugin. Default: 1
`sm_botcon_quota_players` Bot quota when players are connected. Default: 3
`sm_botcon_quota_empty` Bot quota when server is empty. Default: 0

## welcome - Simple Welcome Message

Display a simple welcome message

`sm_welcome_timer` Time in seconds before message is displayed. Default: 10

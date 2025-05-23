# analyzer4d.nvim

Neovim plugin that brings some of the functionality of the [Analyzer4D](https://qass.net/software) 
software to Neovim.

At the moment this is just a convenience project for myself to improve the developer
experience in the Analyzer4D software.

> [!IMPORTANT]
> I am new to neovim plugin development so I might make some changes to the underlying 
> structure which can break things. Sorry in advance for that!

## Installation

- [lazy.nvim]()

```lua
return ({
    "ossmos/analyzer4d.nvim",
    config = function()
        require("analyzer4d").setup({
            host = "127.0.0.1"
        })
    end
})
```

## Extended config

```lua
require("analyzer4d").setup({
    -- the ip address of the Optimizer4D running the Analyzer4D software
    -- If this value is set to nil, the ANALYZER_HOST env variable is used instead
    host = nil,
    
    -- the port of the json communication server
    port = 17000,

    -- tries to auto connect to the Analyzer4D if there is no connection yet
    -- and a command is executed
    auto_connect = true,

    -- automatically connect to the log of the Analyzer4D
    subscribe_log = false,

    -- clear the buffer containing the Analyzer4D logs on exection of analyzer4d.reload_qml()
    clear_log_on_qml_reload = false,

    -- Automatically set the position of the cursor to the bottom of the log buffer when new entries come in if the cursor is not in the log window
    auto_scroll_log = true,

    -- Automatically attempt to reconnect after the connection has been lost
    reconnect = true,
})
```

## User-Commands

The plugin adds a couple of user commands. All of the commands have an "Analyzer"-prefix.

### AnalyzerToggleLog

Toggles the buffer containing the log messages of the Analyzer4D software.

### AnalyzerQmlReload

This command reloads the PenGUI (QML-GUI) of the Analyzer4D software.
This will immediately display the GUI even if it was prior set to `hidden`.

### AnalyzerSetAppVar

This commands sets an application variable (AppVar) in the Analyzer4D software.
You can view those variables under `Tools` &rarr; `Global Application Variable Monitor`
in the software.

> [!NOTE]
> All appvars in the software are strings! 

### StartMeasuring

Starts a measurement in the Analyzer4D software.

### StopMeasuring

Stops a running measurement in the Analyzer4D software.

### AnalyzerSubscribeLog

Subscribe to the log of the Analyzer4D software.

### AnalyzerConnect

Creates the connection to the Analyzer4D json communication server.
This only has to be called if the `always_connect` option is set to `false`,
or if the Analyzer4D software has been restarted.

At the moment there is no automatic reconnect.
The command first checks for the `host` option and then the `ANALYZER_HOST` environment
variable of `host` is not specified. If both are not present, the user is prompted for an ip address.

### AnalyzerRestart

Restarts the Analyzer software after 1 second of idle time.


## Features

Stuff that is already implemented and things that are on my todo list for the near
future. If you have any suggestions feel free to let me know!

- [x] Reload the PenGUI (QML) UI
- [x] Set AppVars
- [x] Start Measurement
- [x] Stop Measurement
- [x] Display Analyzer4D log file
- [x] Automatic reconnect after Analyzer4D restart
- [ ] Get AppVars
- [ ] User Callbacks


## Acknowledgements

This plugin is just another wrapper around the JSON communication server of the 
Analyzer4D software. The credit for that goes to [Qass GmbH](https://qass.net)
and their python [qass-tools-networking](https://pypi.org/project/qass-tools-networking/) project.


local analyzer4d = require("analyzer4d")
vim.api.nvim_create_user_command("AnalyzerConnect", analyzer4d.connect, {})
vim.api.nvim_create_user_command("AnalyzerQmlReload", analyzer4d.reload_qml, {})
vim.api.nvim_create_user_command("AnalyzerSetAppVar", analyzer4d.set_appvar, {})
vim.api.nvim_create_user_command("AnalyzerStartMeasuring", analyzer4d.start_measuring, {})
vim.api.nvim_create_user_command("AnalyzerStopMeasuring", analyzer4d.stop_measuring, {})

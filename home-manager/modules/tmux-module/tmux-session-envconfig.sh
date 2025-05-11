if initialize_session "envconfig"; then
    window_root "$HOME/.config"
    new_window "Config"
    run_cmd "nvim"

    window_root "$HOME/Projects/DevEnvSetup"
    new_window "Setup"
    run_cmd "nvim"

    window_root "$HOME/.config"
    new_window "ConfigGit"
    run_cmd "lazygit"

    window_root "$HOME/Projects/DevEnvSetup"
    new_window "SetupGit"
    run_cmd "lazygit"

    window_root "$HOME/.config"
    new_window "Terminal"
    split_h 50
    run_cmd "cd ~/Projects/DevEnvSetup"
fi

finalize_and_go_to_session
